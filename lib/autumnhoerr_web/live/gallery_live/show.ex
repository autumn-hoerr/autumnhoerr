defmodule AutumnhoerrWeb.GalleryLive.Show do
  @moduledoc """
  `/gallery/:collection/:public_id`: a single artwork.
  """
  use AutumnhoerrWeb, :live_view

  import AutumnhoerrWeb.GalleryComponents

  alias Autumnhoerr.Gallery

  @impl PhoenixPageMeta.LiveView
  def page_meta(socket, _action) do
    %{collection: collection, artwork: artwork} = socket.assigns

    %PhoenixPageMeta.PageMeta{
      title: gettext("%{title} - Autumn Hoerr", title: collection.title),
      path: ~p"/gallery/#{collection.slug}/#{artwork.public_id}",
      description: caption(artwork),
      og_image: "https:" <> image_url(artwork, 1200),
      og_image_alt: artwork.alt
    }
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_section: "gallery")}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"collection" => slug, "public_id" => public_id}, _uri, socket) do
    with {:ok, collection} <- Gallery.get_collection(slug),
         {:ok, artwork} <- Gallery.get_artwork(slug, public_id) do
      {prev, next} = Gallery.neighbours(artwork)

      socket =
        socket
        |> assign(
          collection: collection,
          artwork: artwork,
          back_page: Gallery.page_for(artwork),
          prev: prev,
          next: next
        )
        |> assign_page_meta()

      {:noreply, socket}
    else
      :error -> raise AutumnhoerrWeb.NotFoundError, "no artwork #{inspect(public_id)} in #{slug}"
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="detail">
      <.link class="backlink" navigate={page_path(@collection, @back_page)}>
        {gettext("Back to %{title}", title: @collection.title)}
      </.link>
      <img class="lg-img" alt={@artwork.alt} {image_attrs(@artwork, 1000)} />
      <p>{caption(@artwork)}</p>
      <nav class="detail-nav" aria-label={gettext("More from %{title}", title: @collection.title)}>
        <.link :if={@prev} patch={~p"/gallery/#{@collection.slug}/#{@prev.public_id}"} rel="prev">
          {gettext("Newer")}
        </.link>
        <.link :if={@next} patch={~p"/gallery/#{@collection.slug}/#{@next.public_id}"} rel="next">
          {gettext("Older")}
        </.link>
      </nav>
    </div>
    """
  end
end
