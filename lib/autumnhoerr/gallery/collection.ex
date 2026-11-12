defmodule Autumnhoerr.Gallery.Collection do
  @moduledoc """
  A gallery collection, configured in `config :autumnhoerr, :gallery_collections`.
  Each collection is backed by a single Cloudinary asset folder.
  """

  @enforce_keys [:slug, :title, :folder]
  defstruct [:slug, :title, :blurb, :folder]

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          blurb: String.t() | nil,
          folder: String.t()
        }

  # "p" is reserved for the legacy /gallery/p/:id redirect
  @reserved_slugs ["p"]

  @spec new(map() | keyword()) :: t()
  def new(attrs) do
    collection = struct!(__MODULE__, attrs)

    if collection.slug in @reserved_slugs do
      raise ArgumentError, "gallery collection slug #{inspect(collection.slug)} is reserved"
    end

    collection
  end
end
