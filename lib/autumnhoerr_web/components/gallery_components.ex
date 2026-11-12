defmodule AutumnhoerrWeb.GalleryComponents do
  @moduledoc """
  Components shared by the gallery LiveViews.
  """
  use Phoenix.Component
  use Gettext, backend: AutumnhoerrWeb.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: AutumnhoerrWeb.Endpoint,
    router: AutumnhoerrWeb.Router,
    statics: AutumnhoerrWeb.static_paths()

  alias Autumnhoerr.Cloudinary
  alias Autumnhoerr.Gallery.Artwork

  @doc "Cloudinary URL for an artwork at a given width."
  def image_url(%Artwork{public_id: public_id}, width) do
    Cloudinary.url(public_id, %{width: width, fetch_format: "auto", quality: "auto"})
  end

  @doc "`src`/`srcset`/`width`/`height` attributes for an artwork displayed at `width` px."
  def image_attrs(%Artwork{} = artwork, width) do
    [
      src: image_url(artwork, width),
      srcset: "#{image_url(artwork, width)} 1x, #{image_url(artwork, width * 2)} 2x",
      width: artwork.width && width,
      height: artwork.width && artwork.height && round(artwork.height * width / artwork.width)
    ]
  end

  @doc ~S|Formats a creation date as "August 2026".|
  def format_date(nil), do: nil
  def format_date(%Date{} = date), do: Calendar.strftime(date, "%B %Y")

  @doc "The caption shown under an artwork, e.g. \"acrylic on paper, May 2025\"."
  def caption(%Artwork{} = artwork) do
    [artwork.description, format_date(artwork.date_created)]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  attr :artwork, Artwork, required: true
  attr :lazy, :boolean, default: false

  def gallery_item(assigns) do
    ~H"""
    <.link
      class="gallery-item"
      navigate={~p"/gallery/#{@artwork.collection}/#{@artwork.public_id}"}
    >
      <img alt={@artwork.alt} loading={@lazy && "lazy"} {image_attrs(@artwork, 600)} />
      <p class="gallery-desc">{caption(@artwork)}</p>
    </.link>
    """
  end

  attr :collection, :any, required: true, doc: "the %Gallery.Collection{}"
  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true

  def pagination(assigns) do
    ~H"""
    <nav
      :if={@total_pages > 1}
      class="pagination"
      aria-label={gettext("%{title} pages", title: @collection.title)}
      data-route-announce={
        gettext("%{title}, page %{n} of %{total}",
          title: @collection.title,
          n: @page,
          total: @total_pages
        )
      }
    >
      <%!-- stable ids let app.js restore keyboard focus after a page change --%>
      <.link
        :if={@page > 1}
        id="pagination-prev"
        class="pagination-step pagination-prev"
        patch={page_path(@collection, @page - 1)}
        rel="prev"
      >
        {gettext("Previous")}
      </.link>
      <%!-- keep the slot when there's no previous page so the numbers don't shift --%>
      <span :if={@page == 1} class="pagination-step pagination-prev" aria-disabled="true">
        {gettext("Previous")}
      </span>
      <ol class="pagination-pages">
        <li :for={n <- 1..@total_pages}>
          <.link
            id={"pagination-page-#{n}"}
            class="pagination-page"
            patch={page_path(@collection, n)}
            aria-current={n == @page && "page"}
            aria-label={gettext("Page %{n}", n: n)}
          >
            {n}
          </.link>
        </li>
      </ol>
      <.link
        :if={@page < @total_pages}
        id="pagination-next"
        class="pagination-step pagination-next"
        patch={page_path(@collection, @page + 1)}
        rel="next"
      >
        {gettext("Next")}
      </.link>
      <span
        :if={@page == @total_pages}
        class="pagination-step pagination-next"
        aria-disabled="true"
      >
        {gettext("Next")}
      </span>
    </nav>
    """
  end

  @doc "Path to a page of a collection. Page 1 has no query string."
  def page_path(collection, 1), do: ~p"/gallery/#{collection.slug}"
  def page_path(collection, page), do: ~p"/gallery/#{collection.slug}?#{[page: page]}"
end
