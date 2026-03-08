if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule ShortUUID.Prefixed.Schema do
    @moduledoc """
    A convenience macro for setting up Ecto schemas with prefixed ShortUUID primary keys.

    ## Usage

        defmodule MyApp.User do
          use ShortUUID.Prefixed.Schema, prefix: "usr"

          schema "users" do
            belongs_to :team, MyApp.Team

            timestamps()
          end
        end

    This is equivalent to:

        defmodule MyApp.User do
          use Ecto.Schema

          @primary_key {:id, ShortUUID.Prefixed, prefix: "usr", autogenerate: true}
          @foreign_key_type ShortUUID.Prefixed

          schema "users" do
            belongs_to :team, MyApp.Team

            timestamps()
          end
        end
    """

    defmacro __using__(opts) do
      prefix = Keyword.fetch!(opts, :prefix)

      quote do
        use Ecto.Schema

        @primary_key {:id, ShortUUID.Prefixed, prefix: unquote(prefix), autogenerate: true}
        @foreign_key_type ShortUUID.Prefixed
      end
    end
  end
end
