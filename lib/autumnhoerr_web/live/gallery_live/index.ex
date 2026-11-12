defmodule AutumnhoerrWeb.GalleryLive.Index do
  @moduledoc """
  `/gallery`: every collection with a few preview images and a "view all" link.
  """
  use AutumnhoerrWeb, :live_view

  import AutumnhoerrWeb.GalleryComponents

  alias Autumnhoerr.Gallery

  @preview_count 3

  @impl PhoenixPageMeta.LiveView
  def page_meta(_socket, _action) do
    %PhoenixPageMeta.PageMeta{title: gettext("Gallery - Autumn Hoerr"), path: "/gallery"}
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    collections =
      for collection <- Gallery.list_collections(),
          artworks = Gallery.list_artworks(collection.slug),
          artworks != [] do
        %{
          collection: collection,
          preview: Enum.take(artworks, @preview_count),
          count: length(artworks)
        }
      end

    socket =
      socket
      |> assign(current_section: "gallery", collections: collections)
      |> assign_page_meta()

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <p :if={@collections == []}>
      {gettext("The gallery couldn't be loaded right now. Please check back soon.")}
    </p>
    <section
      :for={%{collection: collection, preview: preview, count: count} <- @collections}
      class={["collection-preview", "gallery-#{collection.slug}"]}
      aria-labelledby={"collection-#{collection.slug}"}
    >
      <header class="collection-title collection-header">
        <h2 id={"collection-#{collection.slug}"} class="collection-heading">
          <.link navigate={~p"/gallery/#{collection.slug}"}>{collection.title}</.link>
        </h2>
        <.link
          class="view-all"
          navigate={~p"/gallery/#{collection.slug}"}
          aria-label={gettext("View all %{count} %{title}", count: count, title: collection.title)}
        >
          {gettext("View All")}
        </.link>
      </header>
      <p :if={collection.blurb}>{collection.blurb}</p>
      <div class="gallery-index">
        <%!-- lazy, so the previews hidden on mobile aren't downloaded there --%>
        <.gallery_item
          :for={{artwork, idx} <- Enum.with_index(preview)}
          artwork={artwork}
          lazy={idx > 0}
        />
      </div>
    </section>
    """
  end
end
