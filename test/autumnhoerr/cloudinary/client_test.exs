defmodule Autumnhoerr.Cloudinary.ClientTest do
  use ExUnit.Case, async: true

  import Autumnhoerr.GalleryFixtures

  alias Autumnhoerr.Cloudinary.Client

  describe "list_folder/1" do
    test "requests the folder with context and metadata, using basic auth" do
      Req.Test.stub(Client, fn conn ->
        assert conn.request_path == "/v1_1/test-cloud/resources/by_asset_folder"

        assert %{
                 "asset_folder" => "paintings",
                 "context" => "true",
                 "metadata" => "true",
                 "max_results" => "500"
               } = URI.decode_query(conn.query_string)

        assert ["Basic " <> encoded] = Plug.Conn.get_req_header(conn, "authorization")
        assert Base.decode64!(encoded) == "test-key:test-secret"

        Req.Test.json(conn, %{"resources" => [resource(%{public_id: "a"})]})
      end)

      assert {:ok, [%{"public_id" => "a"}]} = Client.list_folder("paintings")
    end

    test "follows next_cursor and keeps only images" do
      Req.Test.stub(Client, fn conn ->
        case URI.decode_query(conn.query_string) do
          %{"next_cursor" => "page2"} ->
            Req.Test.json(conn, %{
              "resources" => [resource(%{public_id: "c"}), resource(%{resource_type: "video"})]
            })

          _ ->
            Req.Test.json(conn, %{
              "resources" => [resource(%{public_id: "a"}), resource(%{public_id: "b"})],
              "next_cursor" => "page2"
            })
        end
      end)

      assert {:ok, resources} = Client.list_folder("paintings")
      assert Enum.map(resources, & &1["public_id"]) == ["a", "b", "c"]
    end

    test "maps a 404 to :folder_not_found" do
      Req.Test.stub(Client, &Plug.Conn.send_resp(&1, 404, ""))

      ExUnit.CaptureLog.capture_log(fn ->
        assert {:error, :folder_not_found} = Client.list_folder("nope")
      end)
    end

    test "returns rate limit errors with retry-after" do
      Req.Test.stub(Client, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("retry-after", "120")
        |> Plug.Conn.send_resp(429, "")
      end)

      assert {:error, {:rate_limited, "120"}} = Client.list_folder("paintings")
    end

    test "returns other HTTP errors" do
      Req.Test.stub(Client, &Plug.Conn.send_resp(&1, 500, "oops"))
      assert {:error, {:http_error, 500, "oops"}} = Client.list_folder("paintings")
    end
  end
end
