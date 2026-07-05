defmodule AutumnhoerrWeb.SharedMount do
  @moduledoc """
  A module to hold shared mount logic for LiveViews.
  """
  use Gettext, backend: AutumnhoerrWeb.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: AutumnhoerrWeb.Endpoint,
    router: AutumnhoerrWeb.Router,
    statics: AutumnhoerrWeb.static_paths()

  import Phoenix.Component

  def on_mount(page_atom, _params, _session, socket) do
    socket =
      socket
      |> assign(
        nav_items: [
          %{id: "home", label: gettext("Home"), link: ~p"/"},
          %{id: "gallery", label: gettext("Gallery"), link: ~p"/gallery/"},
          %{id: "about", label: gettext("About"), link: ~p"/about/"}
        ],
        current_section: Atom.to_string(page_atom)
      )

    {:cont, socket}
  end
end
