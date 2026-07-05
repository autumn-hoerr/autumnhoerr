defmodule AutumnhoerrWeb.HomeLive do
  @moduledoc """
  Home page
  """
  use AutumnhoerrWeb, :live_view
  @impl PhoenixPageMeta.LiveView
  def page_meta(_socket, _action) do
    %PhoenixPageMeta.PageMeta{title: gettext("Home - Autumn Hoerr"), path: "/"}
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(current_section: "home")
      |> assign_page_meta()

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <img style="max-width: 100%;" src={Cloudex.Url.for("cover2_okous1")} />
    """
  end
end
