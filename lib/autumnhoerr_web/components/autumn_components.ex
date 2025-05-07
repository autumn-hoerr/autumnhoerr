defmodule AutumnhoerrWeb.Components do
  @moduledoc """
  components... fancy
  """
  use Phoenix.Component

  attr :image_id, :string, required: true, doc: "the cloudinary image id"
  attr :alt, :string, required: true, doc: "do it, asshole"

  def picture(assigns) do
    ~H"""
    <picture>
      <source
        media="(min-width: 800px)"
        srcset="https://res.cloudinary.com/demo/image/upload/ar_2:1,c_fill,g_face/f_auto/q_auto/c_scale,w_800/docs/guitar-man.jpg 800w,
        https://res.cloudinary.com/demo/image/upload/ar_2:1,c_fill,g_face/f_auto/q_auto/c_scale,w_1600/docs/guitar-man.jpg 1600w"
        sizes="100vw"
      />

      <source
        media="(min-width: 600px)"
        srcset="https://res.cloudinary.com/demo/image/upload/f_auto/q_auto/c_scale,w_600/docs/guitar-man.jpg 600w,
        https://res.cloudinary.com/demo/image/upload/f_auto/q_auto/c_scale,w_1200/docs/guitar-man.jpg 1200w"
        sizes="100vw"
      />

      <img
        srcset="https://res.cloudinary.com/demo/image/upload/ar_1:1,c_thumb,g_face/f_auto/q_auto/c_scale,w_400/docs/guitar-man.jpg 400w,
        https://res.cloudinary.com/demo/image/upload/ar_1:1,c_thumb,g_face/f_auto/q_auto/c_scale,w_800/docs/guitar-man.jpg 800w"
        src="https://res.cloudinary.com/demo/image/upload/f_auto/q_auto/c_scale,w_400/docs/guitar-man.jpg"
        alt="Man playing guitar"
        sizes="100vw"
      />
    </picture>
    """
  end
end
