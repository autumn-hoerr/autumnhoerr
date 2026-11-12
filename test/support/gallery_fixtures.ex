defmodule Autumnhoerr.GalleryFixtures do
  @moduledoc """
  Helpers for building Cloudinary resources and artworks in tests.
  """

  alias Autumnhoerr.Gallery.Artwork

  @doc "A resource map shaped like the Admin API `by_asset_folder` response."
  def resource(attrs \\ %{}) do
    id = Map.get(attrs, :public_id, "img_#{System.unique_integer([:positive])}")

    %{
      "asset_id" => "asset_#{id}",
      "public_id" => id,
      "display_name" => id,
      "resource_type" => Map.get(attrs, :resource_type, "image"),
      "type" => "upload",
      "format" => "jpg",
      "width" => 1200,
      "height" => 1600,
      "created_at" => Map.get(attrs, :created_at, "2025-08-17T12:00:00Z"),
      "asset_folder" => "paintings",
      "context" => %{"custom" => %{"alt" => Map.get(attrs, :alt, "alt for #{id}")}},
      "metadata" => %{
        "date_created" => Map.get(attrs, :date_created, "2025-05-01"),
        "art_description" => Map.get(attrs, :description, "acrylic on paper, 9x12")
      }
    }
  end

  @doc "`n` artworks for a collection, newest first."
  def artworks(collection, n) do
    for i <- 1..n//1 do
      %Artwork{
        public_id: "#{collection}_#{i}",
        collection: collection,
        alt: "#{collection} alt #{i}",
        description: "#{collection} description #{i}",
        date_created: Date.add(~D[2026-01-01], -i),
        width: 1200,
        height: 1600
      }
    end
  end
end
