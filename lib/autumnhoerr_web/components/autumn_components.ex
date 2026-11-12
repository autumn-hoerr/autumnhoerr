defmodule AutumnhoerrWeb.Components do
  @moduledoc """
  components... fancy
  """
  use Phoenix.Component
  use Gettext, backend: AutumnhoerrWeb.Gettext

  @external_links [
    {"instagram", "https://www.instagram.com/autumn.hoerr.art/"},
    {"bsky", "https://bsky.app/profile/autumnhoerr.com"},
    {"github", "https://github.com/autumn-hoerr"},
    {"linkedin", "https://www.linkedin.com/in/autumn-hoerr/"},
    {"last.fm", "https://www.last.fm/user/refringence"}
  ]

  attr :nav_items, :list, required: true
  attr :current_section, :string, default: nil
  attr :current_subsection, :string, default: nil, doc: "id of the active child item, if any"
  attr :current_path, :string, default: nil, doc: "path of the current page, for aria-current"

  def nav(assigns) do
    assigns = assign(assigns, :external_links, @external_links)

    ~H"""
    <nav class="nav" aria-label={gettext("Site")}>
      <div>
        <h2 class="nav-label">{gettext("Here:")}</h2>
        <ol class="nav-list">
          <li
            :for={item <- @nav_items}
            class={["nav-item", item[:children] && "nav-item-parent"]}
          >
            <div class="nav-item-row">
              <.current_page_indicator :if={item.id == @current_section} />
              <.link
                navigate={item.link}
                aria-current={aria_current(item.link, @current_path, item.id == @current_section)}
              >
                {item.label}
              </.link>
            </div>
            <ol :if={item[:children]} class="nav-sublist">
              <li :for={child <- item.children} class="nav-subitem">
                <.link
                  navigate={child.link}
                  aria-current={
                    aria_current(
                      child.link,
                      @current_path,
                      item.id == @current_section and child.id == @current_subsection
                    )
                  }
                >
                  {child.label}
                </.link>
              </li>
            </ol>
          </li>
        </ol>
      </div>
      <div>
        <h2 class="nav-label">{gettext("There:")}</h2>
        <ol class="nav-list">
          <li :for={{label, href} <- @external_links} class="nav-item">
            <a target="_blank" href={href}>
              {label}<span class="sr-only">{gettext("(opens in new tab)")}</span>
            </a>
          </li>
        </ol>
      </div>
    </nav>
    """
  end

  # "page" for a link to exactly this page, "true" for an ancestor of it
  # (e.g. Gallery and Paintings while viewing a single painting)
  defp aria_current(link, current_path, in_current_section?) do
    cond do
      current_path && String.trim_trailing(link, "/") == String.trim_trailing(current_path, "/") ->
        "page"

      in_current_section? ->
        "true"

      true ->
        nil
    end
  end

  # decorative; the current page is conveyed to assistive tech via aria-current
  defp current_page_indicator(assigns) do
    ~H"""
    <span class="nav-indicator" aria-hidden="true">❧</span>
    """
  end

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
