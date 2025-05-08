defmodule AutumnhoerrWeb.GalleryLive do
  @moduledoc """
  gallery stuff
  """
  use AutumnhoerrWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     # TODO: don't repeat this
     # on_mount or router plug?
     |> assign(
       nav_items: [
         %{id: "home", label: gettext("Home"), link: ~p"/"},
         %{id: "gallery", label: gettext("Gallery"), link: ~p"/gallery/"},
         %{id: "about", label: gettext("About"), link: ~p"/about/"}
       ],
       current_section: "gallery",
       # TODO: get this from cloudinary
       images: [
         %{
           gallery: nil,
           items: [
             %{
               id: "5125_ymoj0r",
               alt: "alt text",
               date: "May 2025",
               media: "acrylic medium and gouache on paper, 9x12"
             },
             %{
               id: "52225_nsdpcb",
               alt: "alt text",
               date: "May 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "22225_a3o7uv",
               alt: "alt text",
               date: "Feb 2025",
               media: "acrylic medium, mixed media collage, and gouache on paper, 9x12"
             },
             %{
               id: "22125_wluusv",
               alt: "alt text",
               date: "Feb 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "22425_kybna7",
               alt: "alt text",
               date: "Feb 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "22025_conyvc",
               alt: "alt text",
               date: "Feb 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "5325_flnecs",
               alt: "alt text",
               date: "May 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             }
           ]
         },
         %{
           gallery: "Platonic Solids 2025 Edition",
           items: [
             %{
               id: "meta1-tetrahedron_2025_fpmcli",
               alt: "alt text",
               date: "April 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "meta2-hexahedron_2025_w0zmoj",
               alt: "alt text",
               date: "April 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "meta3-octahedron_2025_dnn54k",
               alt: "alt text",
               date: "April 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "meta4-icosahedron_2025_r9wh7q",
               alt: "alt text",
               date: "April 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             },
             %{
               id: "meta5-dodecahedron_2025_amswlj",
               alt: "alt text",
               date: "April 2025",
               media: "acrylic medium and gouache on paper, 8x10"
             }
           ]
         }
       ]
     )}
  end

  def render(assigns) do
    ~H"""
    <.gallery :for={{gallery, idx} <- Enum.with_index(@images, 1)} gallery={gallery} idx={idx} />
    """
  end

  def handle_event("open-modal", _params, socket) do
    # TODO placeholder noop
    {:noreply, socket}
  end

  attr :gallery, :map, required: true

  defp gallery(assigns) do
    ~H"""
    <div class={"gallery" <> to_string(@idx)}>
      <h2 :if={@gallery.gallery}>{@gallery.gallery}</h2>
      <div :for={item <- @gallery.items}>
        <.gallery_item item={item} />
      </div>
    </div>
    """
  end

  attr :item, :map, required: true

  defp gallery_item(assigns) do
    ~H"""
    <a href="#" phx-click="open-modal" phx-value-item={@item.id}>
      <img src={Cloudex.Url.for(@item.id, %{width: 400})} alt={@item.alt} />
      <p class="gallery-desc">{@item.media}, {@item.date}</p>
    </a>
    """
  end
end
