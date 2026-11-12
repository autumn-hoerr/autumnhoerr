defmodule Autumnhoerr.Cloudinary.Client do
  @moduledoc """
  Minimal client for the Cloudinary Admin API.

  Credentials come from `:cloudinary_cloud_name`, `:cloudinary_api_key` and
  `:cloudinary_api_secret` in the `:autumnhoerr` app env. Extra `Req` options
  (e.g. a `Req.Test` plug in tests) can be set with `:cloudinary_req_options`.
  """

  require Logger

  @max_results 500

  @type resource :: map()
  @type error ::
          :folder_not_found
          | :missing_credentials
          | {:rate_limited, retry_after :: String.t() | nil}
          | {:http_error, status :: pos_integer(), body :: term()}
          | Exception.t()

  @doc """
  Lists every image stored directly in a Cloudinary asset folder, including
  contextual metadata (`context`, which holds the alt text) and structured
  metadata (`metadata`).

  Follows `next_cursor` until all pages have been fetched. Requires the
  product environment to use dynamic folder mode.
  """
  @spec list_folder(String.t()) :: {:ok, [resource()]} | {:error, error()}
  def list_folder(folder) when is_binary(folder) do
    with {:ok, req} <- base_request() do
      do_list_folder(req, folder, nil, [])
    end
  end

  defp do_list_folder(req, folder, cursor, acc) do
    params =
      [asset_folder: folder, max_results: @max_results, context: true, metadata: true] ++
        if(cursor, do: [next_cursor: cursor], else: [])

    case Req.get(req, url: "/resources/by_asset_folder", params: params) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        acc = [Map.get(body, "resources", []) | acc]

        case body do
          %{"next_cursor" => next} when is_binary(next) and next != "" ->
            do_list_folder(req, folder, next, acc)

          _ ->
            resources =
              acc
              |> Enum.reverse()
              |> List.flatten()
              |> Enum.filter(&(Map.get(&1, "resource_type", "image") == "image"))

            {:ok, resources}
        end

      {:ok, response} ->
        handle_error_response(response, folder: folder)

      {:error, exception} ->
        {:error, exception}
    end
  end

  @doc """
  Updates an uploaded image's attributes (Admin API "update resource").

  `params` is a keyword list or map of form params such as `context`,
  `metadata`, or `asset_folder`.
  """
  @spec update_image(String.t(), Enumerable.t()) :: {:ok, resource()} | {:error, error()}
  def update_image(public_id, params) do
    with {:ok, req} <- base_request() do
      case Req.post(req,
             url: "/resources/image/upload/#{URI.encode(public_id, &URI.char_unreserved?/1)}",
             form: params
           ) do
        {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
        {:ok, response} -> handle_error_response(response, public_id: public_id)
        {:error, exception} -> {:error, exception}
      end
    end
  end

  defp handle_error_response(%Req.Response{status: 404}, meta) do
    Logger.warning(
      "Cloudinary returned 404 for #{inspect(meta)}. Check that the folder exists " <>
        "and the product environment uses dynamic folder mode."
    )

    {:error, :folder_not_found}
  end

  defp handle_error_response(%Req.Response{status: 429} = response, _meta) do
    {:error, {:rate_limited, response |> Req.Response.get_header("retry-after") |> List.first()}}
  end

  defp handle_error_response(%Req.Response{status: status, body: body}, _meta) do
    {:error, {:http_error, status, body}}
  end

  defp base_request do
    cloud_name = Application.get_env(:autumnhoerr, :cloudinary_cloud_name)
    api_key = Application.get_env(:autumnhoerr, :cloudinary_api_key)
    api_secret = Application.get_env(:autumnhoerr, :cloudinary_api_secret)

    if Enum.all?([cloud_name, api_key, api_secret], &(is_binary(&1) and &1 != "")) do
      req =
        Req.new(
          base_url: "https://api.cloudinary.com/v1_1/#{cloud_name}",
          auth: {:basic, "#{api_key}:#{api_secret}"},
          # failures are handled by the caller (the gallery cache keeps stale data)
          retry: false
        )
        |> Req.merge(Application.get_env(:autumnhoerr, :cloudinary_req_options, []))

      {:ok, req}
    else
      {:error, :missing_credentials}
    end
  end
end
