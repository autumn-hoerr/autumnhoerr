defmodule Autumnhoerr.GalleryTest do
  # the gallery cache is a global ETS table
  use ExUnit.Case, async: false

  import Autumnhoerr.GalleryFixtures
  import ExUnit.CaptureLog

  alias Autumnhoerr.Gallery
  alias Autumnhoerr.Gallery.{Artwork, Cache}

  setup do
    Cache.clear()
    on_exit(&Cache.clear/0)
  end

  describe "Artwork.from_cloudinary/2" do
    test "maps alt text, description and dates" do
      artwork =
        Artwork.from_cloudinary(
          resource(%{
            public_id: "x",
            alt: "a dog",
            description: "gouache",
            date_created: "2025-02-01"
          }),
          "paintings"
        )

      assert %Artwork{
               public_id: "x",
               collection: "paintings",
               alt: "a dog",
               description: "gouache",
               date_created: ~D[2025-02-01],
               width: 1200,
               height: 1600
             } = artwork

      assert artwork.created_at == ~U[2025-08-17 12:00:00Z]
    end

    test "falls back to display_name and logs when alt text is missing" do
      resource = resource(%{public_id: "x"}) |> Map.delete("context")

      log =
        capture_log(fn ->
          assert %Artwork{alt: "x"} = Artwork.from_cloudinary(resource, "paintings")
        end)

      assert log =~ "x has no alt text"
    end

    test "tolerates missing metadata" do
      resource = resource() |> Map.delete("metadata")

      assert %Artwork{description: nil, date_created: nil} =
               Artwork.from_cloudinary(resource, "paintings")
    end
  end

  describe "Artwork.sort/1" do
    test "newest date first, undated last, ties broken by upload time" do
      a = %Artwork{public_id: "a", collection: "c", date_created: ~D[2025-01-01]}
      b = %Artwork{public_id: "b", collection: "c", date_created: ~D[2026-01-01]}
      c = %Artwork{public_id: "c", collection: "c", date_created: nil}

      d = %Artwork{
        public_id: "d",
        collection: "c",
        date_created: ~D[2025-01-01],
        created_at: ~U[2025-06-01 00:00:00Z]
      }

      assert Artwork.sort([a, b, c, d]) |> Enum.map(& &1.public_id) == ["b", "d", "a", "c"]
    end
  end

  describe "page/3" do
    test "with no artworks there is one empty page" do
      assert %{entries: [], page: 1, total: 0, total_pages: 1} = Gallery.page("paintings", 1)
    end

    test "exactly one full page" do
      Cache.put("paintings", artworks("paintings", 8))
      assert %{total_pages: 1, entries: entries} = Gallery.page("paintings", 1)
      assert length(entries) == 8
    end

    test "nine artworks spill onto a second page" do
      Cache.put("paintings", artworks("paintings", 9))

      assert %{page: 2, total_pages: 2, total: 9, entries: [%{public_id: "paintings_9"}]} =
               Gallery.page("paintings", 2)
    end

    test "clamps out-of-range pages" do
      Cache.put("paintings", artworks("paintings", 9))
      assert %{page: 2} = Gallery.page("paintings", 99)
      assert %{page: 1} = Gallery.page("paintings", -3)
    end
  end

  test "page_for/1, neighbours/1 and find_artwork/1" do
    Cache.put("drawings", artworks("drawings", 10))
    {:ok, ninth} = Gallery.get_artwork("drawings", "drawings_9")

    assert Gallery.page_for(ninth) == 2
    assert {%{public_id: "drawings_8"}, %{public_id: "drawings_10"}} = Gallery.neighbours(ninth)
    assert {:ok, ^ninth} = Gallery.find_artwork("drawings_9")
    assert :error = Gallery.find_artwork("missing")
  end

  test "list_collections/0 follows config order" do
    assert Enum.map(Gallery.list_collections(), & &1.slug) == [
             "drawings",
             "paintings",
             "calligraphy"
           ]
  end
end
