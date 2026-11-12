defmodule AutumnhoerrWeb.GalleryRedirectController do
  @moduledoc """
  Permanently redirects legacy `/gallery/p/:id` URLs to
  `/gallery/:collection/:public_id`.
  """
  use AutumnhoerrWeb, :controller

  alias Autumnhoerr.Gallery

  def show(conn, %{"id" => public_id}) do
    case Gallery.find_artwork(public_id) do
      {:ok, artwork} ->
        conn
        |> put_status(:moved_permanently)
        |> redirect(to: ~p"/gallery/#{artwork.collection}/#{artwork.public_id}")

      :error ->
        raise AutumnhoerrWeb.NotFoundError, "no artwork #{inspect(public_id)}"
    end
  end
end
