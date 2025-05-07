defmodule AutumnhoerrWeb.PageController do
  use AutumnhoerrWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    conn
    |> make_title("Home")
    |> assign(:home_image_url, Cloudex.Url.for("cover2_okous1"))
    |> render(:home)
  end

  def gallery(conn, _params) do
    conn
    |> make_title("Gallery")
    |> render(:gallery)
  end

  def about(conn, _params) do
    conn
    |> make_title("About Me")
    |> assign(:about_image_url, Cloudex.Url.for("not-amused_fn36g8"))
    |> render(:about)
  end

  defp make_title(conn, page_title) do
    assign(conn, :page_title, gettext("%{page_title} - Autumn Hoerr", %{page_title: page_title}))
  end
end
