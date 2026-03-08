if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule ShortUUID.Prefixed do
    @moduledoc """
    An Ecto parameterized type that generates prefixed ShortUUIDs.

    Stores standard UUIDs in the database but presents them as prefixed ShortUUIDs
    in your application (e.g., `usr_F6tzXELwufrXBFtFTKsUvc`).

    ## Examples

        @primary_key {:id, ShortUUID.Prefixed, prefix: "usr", autogenerate: true}
        @foreign_key_type ShortUUID.Prefixed

    ## Schema helper

    For convenience, you can use `ShortUUID.Prefixed.Schema` which sets up the
    primary key and foreign key type automatically:

        defmodule MyApp.User do
          use ShortUUID.Prefixed.Schema, prefix: "usr"

          schema "users" do
            # ...
          end
        end
    """

    use Ecto.ParameterizedType

    import ShortUUID.Guards

    @impl true
    def init(opts) do
      schema = Keyword.fetch!(opts, :schema)
      field = Keyword.fetch!(opts, :field)

      if opts[:primary_key] do
        prefix = Keyword.get(opts, :prefix) || raise "`:prefix` option is required"

        %{
          primary_key: true,
          schema: schema,
          prefix: prefix
        }
      else
        %{
          schema: schema,
          field: field
        }
      end
    end

    @impl true
    def type(_params), do: :uuid

    @impl true
    def cast(nil, _params), do: {:ok, nil}

    def cast(data, params) when is_uuid(data) do
      {:ok, uuid_to_slug(data, params)}
    end

    def cast(data, params) do
      with {:ok, prefix, _uuid} <- slug_to_uuid(data, params),
           {prefix, prefix} <- {prefix, prefix(params)} do
        {:ok, data}
      else
        _ -> :error
      end
    end

    @impl true
    def load(nil, _loader, _params), do: {:ok, nil}

    def load(data, _loader, params) do
      case Ecto.UUID.load(data) do
        {:ok, uuid} -> {:ok, uuid_to_slug(uuid, params)}
        :error -> :error
      end
    end

    @impl true
    def dump(nil, _, _), do: {:ok, nil}

    def dump(slug, _dumper, params) do
      case slug_to_uuid(slug, params) do
        {:ok, _prefix, uuid} -> Ecto.UUID.dump(uuid)
        :error -> :error
      end
    end

    @impl true
    def autogenerate(params) do
      uuid_to_slug(Ecto.UUID.autogenerate(), params)
    end

    @impl true
    def embed_as(format, _params), do: Ecto.UUID.embed_as(format)

    @impl true
    def equal?(a, b, _params), do: Ecto.UUID.equal?(a, b)

    defp uuid_to_slug(uuid, params) do
      "#{prefix(params)}_#{ShortUUID.encode!(uuid)}"
    end

    defp slug_to_uuid(string, _params) do
      with [prefix, slug] <- String.split(string, "_"),
           {:ok, uuid} <- ShortUUID.decode(slug) do
        {:ok, prefix, uuid}
      else
        _ -> :error
      end
    end

    defp prefix(%{prefix: prefix}), do: prefix

    # If we deal with a belongs_to association we need to fetch the prefix from
    # the association's schema module.
    defp prefix(%{schema: schema, field: field}) do
      %{related: schema, related_key: field} = schema.__schema__(:association, field)
      {:parameterized, {__MODULE__, %{prefix: prefix}}} = schema.__schema__(:type, field)

      prefix
    end

    @doc """
    Converts a prefixed ShortUUID back to a standard UUID.

    Returns `{:ok, uuid}` on success, `:error` on failure.

    ## Examples

        iex> ShortUUID.Prefixed.to_uuid("usr_99dn6s7bZoVpjzYciVNgN")
        {:ok, "01234567-89ab-cdef-0123-456789abcdef"}

        iex> ShortUUID.Prefixed.to_uuid("invalid")
        :error
    """
    def to_uuid(string) do
      case slug_to_uuid(string, %{}) do
        {:ok, _prefix, uuid} -> {:ok, uuid}
        :error -> :error
      end
    end

    @doc """
    Converts a prefixed ShortUUID back to a standard UUID.

    Raises on invalid input.

    ## Examples

        iex> ShortUUID.Prefixed.to_uuid!("usr_99dn6s7bZoVpjzYciVNgN")
        "01234567-89ab-cdef-0123-456789abcdef"
    """
    def to_uuid!(string) do
      case to_uuid(string) do
        {:ok, uuid} -> uuid
        :error -> raise ArgumentError
      end
    end
  end
end
