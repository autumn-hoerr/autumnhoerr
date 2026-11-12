defmodule AutumnhoerrWeb.Sitemap do
  @moduledoc """
  https://hex.pm/packages/phoenix_press
  """
  use PhoenixPress.Sitemap, base_url: "https://autumnhoerr.com"

  add("/", changefreq: :weekly, priority: 0.8)
  add("/gallery", changefreq: :weekly, priority: 1.0)
  add("/about", changefreq: :monthly, priority: 0.5)

  # Collection pages come from config, so they're known at compile time.
  # Individual images live in Cloudinary and are only known at runtime,
  # so they aren't listed here.
  for collection <- Application.compile_env(:autumnhoerr, :gallery_collections, []) do
    add("/gallery/#{collection.slug}", changefreq: :weekly, priority: 0.9)
  end
end
