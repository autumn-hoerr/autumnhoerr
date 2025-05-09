defmodule AutumnhoerrWeb.GalleryLive do
  @moduledoc """
  gallery stuff
  """
  use AutumnhoerrWeb, :live_view

  @gallery [
    %{
      items: [
        %{
          id: "5125_ymoj0r",
          alt:
            "A primarily blue and purple painting with illegible words scrawled upside down across the top and featuring a field of interconnected circles in the bottom three-quarters.",
          date: "May 2025",
          media: "acrylic medium and gouache on paper, 9x12"
        },
        %{
          id: "52225_nsdpcb",
          alt:
            "An octogon is inscribed in the center of the painting which is split diagonally with the left half being orange and the right half blue and purple.",
          date: "May 2025",
          media: "acrylic medium and gouache on paper, 8x10"
        },
        %{
          id: "22225_a3o7uv",
          alt:
            "An orange and purple abstract painting. Interconnected circles are inscribed in the paint and printed words are illegible underneath the field of colors.",
          date: "Feb 2025",
          media: "acrylic medium, mixed media collage, and gouache on paper, 9x12"
        },
        %{
          id: "22125_wluusv",
          alt:
            "Orange circles and lines dominate the right two-thirds of the painting. The rest is purple, green, and blue. Illegible writing covers the space outside of the geometrical figure.",
          date: "Feb 2025",
          media: "acrylic medium and gouache on paper, 8x10"
        },
        %{
          id: "22425_kybna7",
          alt:
            "An orange hourglass shape of circles takes the right two-thirds. Underneath the purples, blues, and greens outside the geometric figure is a checkerboard pattern",
          date: "Feb 2025",
          media: "acrylic medium, mixed media collage, and gouache on paper, 8x10"
        },
        %{
          id: "22025_conyvc",
          alt:
            "Thirteen interconnected circles make a flower shape in the lower right of this purple, green, and blue painting. Some illegible handwriting overlaps itself above the inscribed shapes.",
          date: "Feb 2025",
          media: "acrylic medium and gouache on paper, 8x10"
        },
        %{
          id: "5325_flnecs",
          alt:
            "An octogon is inscribed in the center of the blue and green painting. At each outer vertex a circle is scratched into the medium, making a flower shape. Within one of the petals some illegible handwriting is scratched into the medium.",
          date: "May 2025",
          media: "acrylic medium and gouache on paper, 8x10"
        }
      ]
    }
  ]

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(
        # TODO: don't repeat this
        # on_mount or router plug?
        page_title: gettext("Gallery - Autumn Hoerr"),
        open_image: nil,
        nav_items: [
          %{id: "home", label: gettext("Home"), link: ~p"/"},
          %{id: "gallery", label: gettext("Gallery"), link: ~p"/gallery/"},
          %{id: "about", label: gettext("About"), link: ~p"/about/"}
        ],
        current_section: "gallery",
        # TODO: get this from cloudinary
        galleries: @gallery
      )
      |> maybe_assign_image_id(Map.get(params, "id"))

    {:ok, socket}
  end

  # skip the nested looping if we know it's nil...
  # still important to assign here for when we're closing an image
  # ... maybe? patch would handle_params would be nil... another night
  defp maybe_assign_image_id(socket, nil),
    do: assign(socket, open_image: nil)

  defp maybe_assign_image_id(socket, img_id) do
    if valid_image_id?(img_id),
      do: assign(socket, open_image: img_id),
      else: socket
  end

  def render(%{open_image: nil} = assigns) do
    ~H"""
    <.gallery :for={{gallery, idx} <- Enum.with_index(@galleries, 1)} gallery={gallery} idx={idx} />
    """
  end

  def render(assigns) do
    # poor decisions compounding
    assigns = assign(assigns, img: get_img(assigns.open_image))

    ~H"""
    <div class={[@current_section, "detail"]}>
      <.link class="backlink" patch={~p"/gallery"}>
        {gettext("Back")}
      </.link>
      <img
        class="lg-img"
        src={Cloudex.Url.for(@img.id, %{width: 800})}
        srcset={Cloudex.Url.for(@img.id, %{width: 800}) <> " 1x, " <> Cloudex.Url.for(@img.id, %{width: 1600}) <> " 2x"}
      />
      <p>{@img.media}, {@img.date}</p>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    socket =
      maybe_assign_image_id(socket, Map.get(params, "id"))

    {:noreply, socket}
  end

  defp valid_image_id?(img_id) do
    # lowkey hate this, probably ought to just put the imgs in a db
    Enum.map(@gallery, fn gallery ->
      Enum.any?(gallery.items, fn item ->
        item.id == img_id
      end)
    end)
    |> Enum.any?()
  end

  defp get_img(img_id) do
    # this too
    @gallery
    |> Enum.map(fn gallery ->
      Enum.find(gallery.items, fn item ->
        item.id == img_id
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.at(0)
  end

  attr :gallery, :map, required: true
  attr :idx, :string, required: true

  defp gallery(assigns) do
    ~H"""
    <div class={"gallery-index gallery" <> to_string(@idx)}>
      <h2 :if={Map.has_key?(@gallery, :name)}>{@gallery.name}</h2>
      <p :if={Map.has_key?(@gallery, :desc)}>{@gallery.desc}</p>
      <.gallery_item :for={item <- @gallery.items} item={item} />
    </div>
    """
  end

  attr :item, :map, required: true

  defp gallery_item(assigns) do
    ~H"""
    <.link class="gallery-item" patch={~p"/gallery/p/#{@item.id}"}>
      <img src={Cloudex.Url.for(@item.id, %{width: 300})} alt={@item.alt} />
      <p class="gallery-desc">{@item.media}, {@item.date}</p>
    </.link>
    """
  end
end
