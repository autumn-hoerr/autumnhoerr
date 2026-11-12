defmodule Autumnhoerr.Gallery.Artwork do
  @moduledoc """
  A single piece of art, normalised from a Cloudinary Admin API resource.

  Cloudinary fields used:

    * `context.custom.alt`: alt text (Cloudinary's built-in "Description (alt)")
    * `metadata.art_description`: brief description, e.g. medium and size
    * `metadata.date_created`: creation date (`YYYY-MM-DD`; displayed as month + year)
  """

  require Logger

  @enforce_keys [:public_id, :collection]
  defstruct [
    :public_id,
    :collection,
    :alt,
    :description,
    :date_created,
    :width,
    :height,
    :created_at
  ]

  @type t :: %__MODULE__{
          public_id: String.t(),
          collection: String.t(),
          alt: String.t(),
          description: String.t() | nil,
          date_created: Date.t() | nil,
          width: pos_integer() | nil,
          height: pos_integer() | nil,
          created_at: DateTime.t() | nil
        }

  @spec from_cloudinary(map(), String.t()) :: t()
  def from_cloudinary(%{"public_id" => public_id} = resource, collection_slug) do
    metadata = Map.get(resource, "metadata") || %{}

    %__MODULE__{
      public_id: public_id,
      collection: collection_slug,
      alt: alt_text(resource),
      description: blank_to_nil(metadata["art_description"]),
      date_created: parse_date(metadata["date_created"]),
      width: resource["width"],
      height: resource["height"],
      created_at: parse_datetime(resource["created_at"])
    }
  end

  defp alt_text(resource) do
    case get_in(resource, ["context", "custom", "alt"]) |> blank_to_nil() do
      nil ->
        Logger.warning("Cloudinary image #{resource["public_id"]} has no alt text")
        blank_to_nil(resource["display_name"]) || ""

      alt ->
        alt
    end
  end

  defp parse_date(value) when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp parse_date(_), do: nil

  defp parse_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

  defp parse_datetime(_), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp blank_to_nil(_), do: nil

  @doc """
  Sorts artworks newest first by `date_created`. Artworks without a date go
  last; ties are broken by Cloudinary upload time (newest first).
  """
  @spec sort([t()]) :: [t()]
  def sort(artworks) do
    Enum.sort_by(artworks, &sort_key/1, :desc)
  end

  defp sort_key(%__MODULE__{date_created: date, created_at: created_at}) do
    {
      if(date, do: 1, else: 0),
      if(date, do: Date.to_gregorian_days(date), else: 0),
      if(created_at, do: DateTime.to_unix(created_at), else: 0)
    }
  end
end
