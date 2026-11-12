defmodule Autumnhoerr.Gallery do
  @moduledoc """
  The art gallery. Collections are configured in
  `config :autumnhoerr, :gallery_collections`; artworks come from Cloudinary
  asset folders via `Autumnhoerr.Gallery.Cache`.
  """

  alias Autumnhoerr.Gallery.{Artwork, Cache, Collection}

  @per_page 8

  @type page :: %{
          entries: [Artwork.t()],
          page: pos_integer(),
          per_page: pos_integer(),
          total: non_neg_integer(),
          total_pages: pos_integer()
        }

  def per_page, do: @per_page

  @doc "All configured collections, in display order."
  @spec list_collections() :: [Collection.t()]
  def list_collections do
    :autumnhoerr
    |> Application.get_env(:gallery_collections, [])
    |> Enum.map(&Collection.new/1)
  end

  @spec get_collection(String.t()) :: {:ok, Collection.t()} | :error
  def get_collection(slug) do
    case Enum.find(list_collections(), &(&1.slug == slug)) do
      nil -> :error
      collection -> {:ok, collection}
    end
  end

  @doc "All artworks in a collection, newest first."
  @spec list_artworks(String.t()) :: [Artwork.t()]
  def list_artworks(slug), do: Cache.get(slug)

  @doc "The first `n` artworks in a collection."
  @spec preview(String.t(), non_neg_integer()) :: [Artwork.t()]
  def preview(slug, n \\ 3), do: slug |> list_artworks() |> Enum.take(n)

  @doc """
  A page of artworks. `page` is clamped to the valid range, so the returned
  `:page` may differ from the requested one.
  """
  @spec page(String.t(), integer(), pos_integer()) :: page()
  def page(slug, page, per_page \\ @per_page) do
    artworks = list_artworks(slug)
    total = length(artworks)
    total_pages = max(1, ceil(total / per_page))
    page = page |> max(1) |> min(total_pages)

    %{
      entries: artworks |> Enum.drop((page - 1) * per_page) |> Enum.take(per_page),
      page: page,
      per_page: per_page,
      total: total,
      total_pages: total_pages
    }
  end

  @spec get_artwork(String.t(), String.t()) :: {:ok, Artwork.t()} | :error
  def get_artwork(slug, public_id) do
    case Enum.find(list_artworks(slug), &(&1.public_id == public_id)) do
      nil -> :error
      artwork -> {:ok, artwork}
    end
  end

  @doc "Finds an artwork by public ID in any collection."
  @spec find_artwork(String.t()) :: {:ok, Artwork.t()} | :error
  def find_artwork(public_id) do
    Enum.find_value(list_collections(), :error, fn collection ->
      case get_artwork(collection.slug, public_id) do
        {:ok, artwork} -> {:ok, artwork}
        :error -> nil
      end
    end)
  end

  @doc "The page number (1-based) of the collection page containing an artwork."
  @spec page_for(Artwork.t(), pos_integer()) :: pos_integer()
  def page_for(%Artwork{} = artwork, per_page \\ @per_page) do
    case Enum.find_index(list_artworks(artwork.collection), &(&1.public_id == artwork.public_id)) do
      nil -> 1
      index -> div(index, per_page) + 1
    end
  end

  @doc "The previous (newer) and next (older) artworks in the same collection."
  @spec neighbours(Artwork.t()) :: {Artwork.t() | nil, Artwork.t() | nil}
  def neighbours(%Artwork{} = artwork) do
    artworks = list_artworks(artwork.collection)

    case Enum.find_index(artworks, &(&1.public_id == artwork.public_id)) do
      nil ->
        {nil, nil}

      index ->
        prev = if index > 0, do: Enum.at(artworks, index - 1)
        {prev, Enum.at(artworks, index + 1)}
    end
  end
end
