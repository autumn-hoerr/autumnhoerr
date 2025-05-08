defmodule AutumnhoerrWeb.PageController do
  use AutumnhoerrWeb, :controller
  plug :put_current_section
  plug :put_nav_items

  def home(conn, _params) do
    conn
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
    |> assign(:about_image_url, Cloudex.Url.for("autumn-hoerr_dqzzyk", %{width: 400}))
    |> render(:about)
  end

  defp put_current_section(conn, _) do
    template =
      conn
      |> Phoenix.Controller.action_name()
      |> Atom.to_string()

    assign(conn, :current_section, template)
  end

  # I'm sorry, Angela. I give up.
  defp put_nav_items(conn, _) do
    items = [
      %{id: "home", label: gettext("Home"), link: ~p"/"},
      %{id: "gallery", label: gettext("Gallery"), link: ~p"/gallery/"},
      %{id: "about", label: gettext("About"), link: ~p"/about/"}
    ]

    assign(conn, :nav_items, items)
  end

  defp make_title(conn, page_title) do
    assign(conn, :page_title, gettext("%{page_title} - Autumn Hoerr", %{page_title: page_title}))
  end
end
