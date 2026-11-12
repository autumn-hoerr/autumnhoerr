defmodule AutumnhoerrWeb.GalleryLive.Collection do
  @moduledoc """
  `/gallery/:collection?page=N`: a paginated grid of one collection.
  """
  use AutumnhoerrWeb, :live_view

  import AutumnhoerrWeb.GalleryComponents

  alias Autumnhoerr.Gallery

  @impl PhoenixPageMeta.LiveView
  def page_meta(socket, _action) do
    %{collection: collection, page: page} = socket.assigns

    title =
      if page.page > 1,
        do: gettext("%{title} - page %{n} - Autumn Hoerr", title: collection.title, n: page.page),
        else: gettext("%{title} - Autumn Hoerr", title: collection.title)

    %PhoenixPageMeta.PageMeta{
      title: title,
      path: page_path(collection, page.page),
      description: collection.blurb
    }
  end

  @impl Phoenix.LiveView
  def mount(%{"collection" => slug}, _session, socket) do
    case Gallery.get_collection(slug) do
      {:ok, collection} ->
        {:ok,
         assign(socket,
           current_section: "gallery",
           current_subsection: collection.slug,
           collection: collection
         )}

      :error ->
        raise AutumnhoerrWeb.NotFoundError, "no gallery collection #{inspect(slug)}"
    end
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    raw_page = params["page"]
    requested = parse_page(raw_page)
    page = Gallery.page(socket.assigns.collection.slug, requested || 1)

    # keep the URL canonical: bad/out-of-range pages and "?page=1" go to the real page
    if raw_page != nil and (requested != page.page or page.page == 1) do
      {:noreply, push_patch(socket, to: page_path(socket.assigns.collection, page.page))}
    else
      {:noreply, socket |> assign(page: page) |> assign_page_meta()}
    end
  end

  defp parse_page(nil), do: nil

  defp parse_page(value) do
    case Integer.parse(value) do
      {n, ""} -> n
      _ -> nil
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.link class="backlink" navigate={~p"/gallery"}>{gettext("Gallery")}</.link>
    <h2 class="collection-title collection-heading">{@collection.title}</h2>
    <p :if={@collection.blurb}>{@collection.blurb}</p>
    <p :if={@page.total == 0}>
      {gettext("Nothing here yet. Please check back soon.")}
    </p>
    <div class={["gallery-index", "gallery-#{@collection.slug}"]}>
      <.gallery_item
        :for={{artwork, idx} <- Enum.with_index(@page.entries)}
        artwork={artwork}
        lazy={idx >= 2}
      />
    </div>
    <.pagination collection={@collection} page={@page.page} total_pages={@page.total_pages} />
    """
  end
end
