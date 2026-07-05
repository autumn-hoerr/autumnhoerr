defmodule AutumnhoerrWeb.Sitemap do
  @moduledoc """
  https://hex.pm/packages/phoenix_press
  """
  use PhoenixPress.Sitemap, base_url: "https://autumnhoerr.com"

  add("/", changefreq: :weekly, priority: 0.8)
  add("/gallery", changefreq: :weekly, priority: 1.0)
  add("/about", changefreq: :monthly, priority: 0.5)

  [gallery_data] = AutumnhoerrWeb.GalleryData.gallery_data()

  for image <- gallery_data.items do
    add("/gallery/p/#{image.id}", changefreq: :monthly, priority: 0.5)
  end
end
