defmodule AutumnhoerrWeb.NotFoundError do
  @moduledoc """
  Raise from a LiveView or controller to render the 404 page.
  """
  defexception message: "not found", plug_status: 404
end
