defmodule AutumnhoerrWeb.Components.Navigation do
  @moduledoc """
  the nav menu
  """
  use AutumnhoerrWeb, :html

  def nav(assigns) do
    ~H"""
    <nav class="nav">
      <h2 id="here" class="nav-label">{gettext("Here:")}</h2>
      <ol class="nav-list" aria-labelledby="here">
        <li><a href={~p"/"}>{gettext("Home")}</a></li>
        <li><a href={~p"/gallery"}>{gettext("Gallery")}</a></li>
        <li><a href={~p"/about"}>{gettext("About")}</a></li>
      </ol>
      <h2 id="there" class="nav-label">{gettext("There: ")}</h2>
      <ol class="nav-list" aria-labelledby="there">
        <li>
          <a target="_blank" href="https://bsky.app/profile/refringence.bsky.social">
            {gettext("bsky")}
          </a>
        </li>
        <li>
          <a target="_blank" href="https://github.com/autumn-hoerr">
            {gettext("github")}
          </a>
        </li>
        <li>
          <a target="_blank" href="https://www.linkedin.com/in/autumn-hoerr/">
            {gettext("linkedin")}
          </a>
        </li>
      </ol>
    </nav>
    """
  end
end
