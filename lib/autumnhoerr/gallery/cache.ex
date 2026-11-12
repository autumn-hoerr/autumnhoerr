defmodule Autumnhoerr.Gallery.Cache do
  @moduledoc """
  Caches gallery artworks fetched from Cloudinary in ETS.

  Readers go straight to ETS (no GenServer call). The GenServer refreshes
  every collection on start (asynchronously) and then on an interval. If a
  refresh fails, the previously cached artworks are kept.

  Configure with:

      config :autumnhoerr, Autumnhoerr.Gallery.Cache,
        refresh_on_start: true,
        refresh_interval: :timer.minutes(30),
        retry_interval: :timer.minutes(1)

  After uploading new art, `Autumnhoerr.Gallery.Cache.refresh_now()` from a
  remote console picks it up immediately.
  """

  use GenServer
  require Logger

  alias Autumnhoerr.Cloudinary.Client
  alias Autumnhoerr.Gallery
  alias Autumnhoerr.Gallery.Artwork

  @table __MODULE__

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Returns the cached artworks for a collection slug (`[]` if not loaded)."
  @spec get(String.t()) :: [Artwork.t()]
  def get(slug) do
    case :ets.lookup(@table, slug) do
      [{^slug, artworks}] -> artworks
      [] -> []
    end
  rescue
    ArgumentError -> []
  end

  @doc "Stores artworks for a collection slug. They are sorted before storing."
  @spec put(String.t(), [Artwork.t()]) :: true
  def put(slug, artworks) do
    :ets.insert(@table, {slug, Artwork.sort(artworks)})
  end

  @doc "Removes every cached collection."
  def clear, do: :ets.delete_all_objects(@table)

  @doc """
  Refreshes all collections from Cloudinary synchronously. Returns a map of
  slug => `:ok | {:error, reason}`.
  """
  def refresh_now(timeout \\ 60_000) do
    GenServer.call(__MODULE__, :refresh, timeout)
  end

  @impl GenServer
  def init(opts) do
    config = Keyword.merge(Application.get_env(:autumnhoerr, __MODULE__, []), opts)

    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])

    if Keyword.get(config, :refresh_on_start, true), do: send(self(), :refresh)

    {:ok,
     %{
       refresh_interval: Keyword.get(config, :refresh_interval, :timer.minutes(30)),
       retry_interval: Keyword.get(config, :retry_interval, :timer.minutes(1)),
       timer: nil
     }}
  end

  @impl GenServer
  def handle_info(:refresh, state) do
    {_results, state} = do_refresh(state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:refresh, _from, state) do
    {results, state} = do_refresh(state)
    {:reply, results, state}
  end

  defp do_refresh(state) do
    if state.timer, do: Process.cancel_timer(state.timer)

    results =
      Map.new(Gallery.list_collections(), fn collection ->
        {collection.slug, refresh_collection(collection)}
      end)

    # retry sooner if a collection failed and we have nothing to show for it
    missing_data? =
      Enum.any?(results, fn {slug, result} -> result != :ok and get(slug) == [] end)

    interval = if missing_data?, do: state.retry_interval, else: state.refresh_interval
    timer = Process.send_after(self(), :refresh, interval)

    {results, %{state | timer: timer}}
  end

  defp refresh_collection(collection) do
    case Client.list_folder(collection.folder) do
      {:ok, resources} ->
        artworks = Enum.map(resources, &Artwork.from_cloudinary(&1, collection.slug))
        put(collection.slug, artworks)
        :ok

      {:error, reason} = error ->
        Logger.error(
          "Failed to refresh gallery collection #{collection.slug} " <>
            "(folder #{inspect(collection.folder)}): #{inspect(reason)}"
        )

        error
    end
  end
end
