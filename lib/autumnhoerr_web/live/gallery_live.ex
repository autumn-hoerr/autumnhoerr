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
          media: "acrylic medium, mixed media collage, and gouache on paper, 8x10"
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
      name: "Platonic Solids 2025 Edition",
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

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(
        # TODO: don't repeat this
        # on_mount or router plug?
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
    <div class={"gallery gallery" <> to_string(@idx)}>
      <h2 :if={Map.has_key?(@gallery, :name)}>{@gallery.name}</h2>
      <p :if={Map.has_key?(@gallery, :desc)}>{@gallery.desc}</p>
      <.gallery_item :for={item <- @gallery.items} item={item} />
    </div>
    """
  end

  attr :item, :map, required: true

  defp gallery_item(assigns) do
    ~H"""
    <.link patch={~p"/gallery/p/#{@item.id}"}>
      <img src={Cloudex.Url.for(@item.id, %{width: 400})} alt={@item.alt} />
      <p class="gallery-desc">{@item.media}, {@item.date}</p>
    </.link>
    """
  end
end
