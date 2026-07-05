defmodule AutumnhoerrWeb.HomeLive do
  @moduledoc """
  Home page
  """
  use AutumnhoerrWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        page_title: gettext("Home - Autumn Hoerr"),
        current_section: "home"
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <img style="max-width: 100%;" src={Cloudex.Url.for("cover2_okous1")} />
    """
  end
end
