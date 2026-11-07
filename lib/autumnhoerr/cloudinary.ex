defmodule Autumnhoerr.Cloudinary do
  @moduledoc """
  Builds Cloudinary delivery URLs for images.

  The cloud name comes from `config :autumnhoerr, :cloudinary_cloud_name`.
  """

  @transformations [
    aspect_ratio: "ar",
    crop: "c",
    fetch_format: "f",
    gravity: "g",
    height: "h",
    quality: "q",
    width: "w"
  ]

  @doc """
  Returns the URL for an image's public ID, optionally transformed.

      iex> Autumnhoerr.Cloudinary.url("a_public_id", %{width: 400})
      "//res.cloudinary.com/my_cloud/image/upload/w_400/a_public_id"
  """
  @spec url(String.t(), map()) :: String.t()
  def url(public_id, options \\ %{}) do
    transformation =
      options
      |> Enum.sort()
      |> Enum.map(fn {key, value} -> "#{Keyword.fetch!(@transformations, key)}_#{value}" end)
      |> Enum.join(",")

    ["//res.cloudinary.com", cloud_name(), "image/upload", transformation, public_id]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("/")
  end

  defp cloud_name, do: Application.fetch_env!(:autumnhoerr, :cloudinary_cloud_name)
end
