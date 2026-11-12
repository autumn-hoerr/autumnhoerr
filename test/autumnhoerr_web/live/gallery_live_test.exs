defmodule AutumnhoerrWeb.GalleryLiveTest do
  # the gallery cache is a global ETS table
  use AutumnhoerrWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Autumnhoerr.GalleryFixtures

  alias Autumnhoerr.Gallery.Cache

  setup do
    Cache.clear()
    on_exit(&Cache.clear/0)
  end

  describe "index" do
    test "shows three images per collection and a view-all link", %{conn: conn} do
      Cache.put("paintings", artworks("paintings", 5))
      Cache.put("drawings", artworks("drawings", 2))

      {:ok, view, html} = live(conn, ~p"/gallery")
      doc = Floki.parse_document!(html)

      view_all = view |> element(".gallery-paintings .collection-header .view-all") |> render()
      assert view_all =~ "View All"
      assert view_all =~ ~s|aria-label="View all 5 Paintings"|

      assert doc |> Floki.find(".gallery-paintings img") |> length() == 3
      assert doc |> Floki.find(".gallery-drawings img") |> length() == 2
      assert has_element?(view, ~s|a.view-all[href="/gallery/drawings"]|)
      assert has_element?(view, ~s|img[alt="paintings alt 1"]|)
    end

    test "shows a message when nothing is loaded", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/gallery")
      assert html =~ "couldn&#39;t be loaded"
    end
  end

  describe "collection" do
    setup do
      Cache.put("paintings", artworks("paintings", 10))
      :ok
    end

    test "shows eight per page with pagination", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/gallery/paintings")

      assert html |> Floki.parse_document!() |> Floki.find(".gallery-item") |> length() == 8
      assert has_element?(view, ~s|nav.pagination a[aria-current="page"]|, "1")
      assert has_element?(view, ~s|a[rel="next"][href="/gallery/paintings?page=2"]|)
      assert html =~ "paintings description 1, December 2025"
    end

    test "second page", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/gallery/paintings?page=2")

      assert html |> Floki.parse_document!() |> Floki.find(".gallery-item") |> length() == 2
      assert has_element?(view, ~s|a[aria-current="page"]|, "2")
      assert has_element?(view, ~s|a[rel="prev"][href="/gallery/paintings"]|)
      assert page_title(view) =~ "Paintings - page 2"
    end

    test "patches between pages", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/gallery/paintings")
      view |> element(~s|a[rel="next"]|) |> render_click()
      assert_patch(view, ~p"/gallery/paintings?page=2")
    end

    test "out-of-range and invalid pages are canonicalised", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/gallery/paintings?page=2"}}} =
               live(conn, ~p"/gallery/paintings?page=99")

      assert {:error, {:live_redirect, %{to: "/gallery/paintings"}}} =
               live(conn, ~p"/gallery/paintings?page=abc")

      assert {:error, {:live_redirect, %{to: "/gallery/paintings"}}} =
               live(conn, ~p"/gallery/paintings?page=1")
    end

    test "unknown collections 404", %{conn: conn} do
      assert_raise AutumnhoerrWeb.NotFoundError, fn -> live(conn, ~p"/gallery/sculptures") end
    end
  end

  describe "show" do
    setup do
      Cache.put("drawings", artworks("drawings", 10))
      :ok
    end

    test "shows the artwork with a link back to its page", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/gallery/drawings/drawings_9")

      assert has_element?(view, ~s|img.lg-img[alt="drawings alt 9"]|)
      assert html =~ "drawings description 9"
      assert has_element?(view, ~s|a.backlink[href="/gallery/drawings?page=2"]|)
      assert has_element?(view, ~s|a[rel="prev"][href="/gallery/drawings/drawings_8"]|)
      assert has_element?(view, ~s|a[rel="next"][href="/gallery/drawings/drawings_10"]|)
    end

    test "unknown artwork 404s", %{conn: conn} do
      assert_raise AutumnhoerrWeb.NotFoundError, fn -> live(conn, ~p"/gallery/drawings/nope") end
    end
  end

  describe "nav" do
    test "lists every collection under Gallery", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/about")

      for slug <- ~w(drawings paintings calligraphy) do
        assert has_element?(view, ~s|.nav-item-parent .nav-sublist a[href="/gallery/#{slug}"]|)
      end

      refute has_element?(view, ~s|.nav-sublist a[aria-current]|)
    end

    test "marks the current collection, including on artwork pages", %{conn: conn} do
      Cache.put("drawings", artworks("drawings", 1))

      {:ok, view, _html} = live(conn, ~p"/gallery/paintings")
      assert has_element?(view, ~s|.nav-sublist a[aria-current="page"]|, "Paintings")
      assert has_element?(view, ~s|.nav-item-row a[aria-current="true"]|, "Gallery")
      assert has_element?(view, ".nav-item-parent > .nav-item-row .nav-indicator")
      refute has_element?(view, ".nav-sublist .nav-indicator")

      # inside a collection, not on its page: "true" rather than "page"
      {:ok, view, _html} = live(conn, ~p"/gallery/drawings/drawings_1")
      assert has_element?(view, ~s|.nav-sublist a[aria-current="true"]|, "Drawings")
      refute has_element?(view, ~s|nav.nav a[aria-current="page"]|)

      {:ok, view, _html} = live(conn, ~p"/gallery")
      refute has_element?(view, ~s|.nav-sublist a[aria-current]|)
      assert has_element?(view, ~s|.nav-item-row a[aria-current="page"]|, "Gallery")
      assert has_element?(view, ".nav-item-parent > .nav-item-row .nav-indicator")
    end

    test "is labelled, hides the decorative indicator, and flags new tabs", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/about")

      assert has_element?(view, ~s|nav.nav[aria-label="Site"]|)
      assert has_element?(view, ~s|.nav-indicator[aria-hidden="true"]|)
      assert has_element?(view, ~s|.nav-item-row a[aria-current="page"]|, "About")
      assert has_element?(view, ~s|a[target="_blank"] .sr-only|, "opens in new tab")
    end
  end

  describe "navigation accessibility" do
    test "skip link targets a focusable main", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/gallery")

      assert has_element?(view, ~s|a.skip-link[href="#main"]|, "Skip to content")
      assert has_element?(view, ~s|main#main[tabindex="-1"]|)
    end

    test "pagination has stable ids and an announcement", %{conn: conn} do
      Cache.put("paintings", artworks("paintings", 20))
      {:ok, view, _html} = live(conn, ~p"/gallery/paintings?page=2")

      assert has_element?(view, ~s|nav.pagination[data-route-announce="Paintings, page 2 of 3"]|)
      assert has_element?(view, "#pagination-prev")
      assert has_element?(view, "#pagination-page-2")
      assert has_element?(view, "#pagination-next")
    end

    test "artwork caption is announced and newer/older have stable ids", %{conn: conn} do
      Cache.put("drawings", artworks("drawings", 3))
      {:ok, view, _html} = live(conn, ~p"/gallery/drawings/drawings_2")

      assert has_element?(view, "p[data-route-announce]", "drawings description 2")
      assert has_element?(view, ~s|#artwork-newer[rel="prev"]|)
      assert has_element?(view, ~s|#artwork-older[rel="next"]|)
    end
  end

  describe "legacy /gallery/p/:id" do
    test "redirects permanently to the new URL", %{conn: conn} do
      Cache.put("drawings", artworks("drawings", 1))
      conn = get(conn, "/gallery/p/drawings_1")
      assert redirected_to(conn, 301) == "/gallery/drawings/drawings_1"
    end

    test "404s for unknown images", %{conn: conn} do
      assert_error_sent 404, fn -> get(conn, "/gallery/p/nope") end
    end
  end
end
