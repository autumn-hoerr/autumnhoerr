defmodule AutumnhoerrWeb.PageController do
  use AutumnhoerrWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(make_title("Home", conn), :home)
  end

  defp make_title(page_title, conn) do
    conn
    |> assign(:page_title, gettext("%{page_title} - Autumn Hoerr", %{page_title: page_title}))
  end
end
