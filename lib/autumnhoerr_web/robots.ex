defmodule AutumnhoerrWeb.Robots do
  use PhoenixPress.Robots, base_url: "https://autumnhoerr.com"

  sitemap("/sitemap.xml")
  allow("/")
  disallow("/dashboard")
end
