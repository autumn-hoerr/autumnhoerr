defmodule AutumnhoerrWeb.AboutLive do
  @moduledoc """
  About page
  """
  use AutumnhoerrWeb, :live_view

  @impl PhoenixPageMeta.LiveView
  def page_meta(_socket, _action) do
    %PhoenixPageMeta.PageMeta{title: gettext("About Me - Autumn Hoerr"), path: "/about"}
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(current_section: "about")
      |> assign_page_meta()

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <img class="portrait" src={Cloudex.Url.for("autumn-hoerr_dqzzyk", %{width: 400})} />
    <p class="first-char">
      When someone inevitably has to put some remarks together after I die I hope they lead off with "She was always so curious." I make a paycheck as a software developer, but have also had the good fortune to be a parent, friend, artist, maker, musician, amateur blacksmith, scuba diver, poet, carpenter, and so many other things over the years. I love collecting new information, hobbies, and experiences.
    </p>
    <p>
      I live and work in Wilmington, North Carolina. I have a thing for textures and patterns; visual, tactile, and auditory. My work explores <em>me</em>&mdash;parts of it tend to be impulsive and automatic while other elements are more considered and methodical. Sometimes it's about spending some time with a color or an idea. Other times it's about my mood or a phrase stuck in my head.
    </p>
    """
  end
end
