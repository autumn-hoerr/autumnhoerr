defmodule AutumnhoerrWeb.GalleryLive do
  @moduledoc """
  gallery stuff
  """
  use AutumnhoerrWeb, :live_view
  @impl PhoenixPageMeta.LiveView
  def page_meta(_socket, _action) do
    %PhoenixPageMeta.PageMeta{title: gettext("Gallery - Autumn Hoerr"), path: "/gallery"}
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(
        current_section: "gallery",
        open_image: nil,
        # TODO: get this from cloudinary
        galleries: AutumnhoerrWeb.GalleryData.gallery_data()
      )
      |> maybe_assign_image_id(Map.get(params, "id"))
      |> assign_page_meta()

    {:ok, socket}
  end

  # skip the nested looping if we know it's nil...
  # still important to assign here for when we're closing an image
  # ... maybe? patch would handle_params would be nil... another night
  defp maybe_assign_image_id(socket, nil),
    do: assign(socket, open_image: nil)

  defp maybe_assign_image_id(socket, img_id) do
    if valid_image_id?(img_id, socket.assigns.galleries),
      do: assign(socket, open_image: img_id),
      else: socket
  end

  @impl Phoenix.LiveView
  def render(%{open_image: nil} = assigns) do
    ~H"""
    <.gallery
      :for={{gallery, idx} <- @galleries |> Enum.reverse() |> Enum.with_index(1)}
      gallery={gallery}
      idx={idx}
    />
    """
  end

  def render(assigns) do
    # poor decisions compounding
    assigns = assign(assigns, img: get_img(assigns.open_image, assigns.galleries))

    ~H"""
    <div class={[@current_section, "detail"]}>
      <.link class="backlink" patch={~p"/gallery"}>
        {gettext("Back")}
      </.link>
      <img
        class="lg-img"
        alt={@img.alt}
        src={Cloudex.Url.for(@img.id, %{width: 1000})}
        srcset={Cloudex.Url.for(@img.id, %{width: 1000}) <> " 1x, " <> Cloudex.Url.for(@img.id, %{width: 2000}) <> " 2x"}
      />
      <p>{@img.media}, {@img.date}</p>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    socket =
      maybe_assign_image_id(socket, Map.get(params, "id"))

    {:noreply, socket}
  end

  defp valid_image_id?(img_id, galleries) do
    # lowkey hate this, probably ought to just put the imgs in a db
    Enum.map(galleries, fn gallery ->
      Enum.any?(gallery.items, fn item ->
        item.id == img_id
      end)
    end)
    |> Enum.any?()
  end

  defp get_img(img_id, galleries) do
    # this too
    galleries
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
      <img
        src={Cloudex.Url.for(@item.id, %{width: 600})}
        alt={@item.alt}
        srcset={Cloudex.Url.for(@item.id, %{width: 600}) <> " 1x, " <> Cloudex.Url.for(@item.id, %{width: 1200}) <> " 2x"}
      />
      <p class="gallery-desc">{@item.media}, {@item.date}</p>
    </.link>
    """
  end
end
