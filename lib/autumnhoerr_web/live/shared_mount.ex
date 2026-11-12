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

  def on_mount(_, _params, _session, socket) do
    socket =
      socket
      |> assign(
        nav_items: [
          %{id: "home", label: gettext("Home"), link: ~p"/"},
          %{
            id: "gallery",
            label: gettext("Gallery"),
            link: ~p"/gallery/",
            children:
              for collection <- Autumnhoerr.Gallery.list_collections() do
                %{
                  id: collection.slug,
                  label: collection.title,
                  link: ~p"/gallery/#{collection.slug}"
                }
              end
          },
          %{id: "about", label: gettext("About"), link: ~p"/about/"}
        ],
        current_path: nil
      )
      |> Phoenix.LiveView.attach_hook(:current_path, :handle_params, fn _params, uri, socket ->
        {:cont, assign(socket, current_path: URI.parse(uri).path)}
      end)

    {:cont, socket}
  end
end
