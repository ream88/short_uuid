if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule ShortUUID.PrefixedTest do
    use ExUnit.Case, async: true
    use ExUnitProperties

    alias ShortUUID.Prefixed

    doctest Prefixed

    defmodule TestSchema do
      @moduledoc false
      use Ecto.Schema

      @primary_key {:id, Prefixed, prefix: "tst", autogenerate: true}
      @foreign_key_type Prefixed

      schema "test" do
        belongs_to(:test, TestSchema)
      end
    end

    @params Prefixed.init(
              schema: TestSchema,
              field: :id,
              primary_key: true,
              autogenerate: true,
              prefix: "tst"
            )
    @belongs_to_params Prefixed.init(schema: TestSchema, field: :test, foreign_key: :test_id)
    @loader nil
    @dumper nil

    test "cast/2 roundtrips through dump/3" do
      check all(uuid <- ShortUUID.Generators.uuid()) do
        {:ok, slug} = Prefixed.cast(uuid, @params)
        {:ok, raw} = Prefixed.dump(slug, @dumper, @params)
        {:ok, ^slug} = Prefixed.cast(slug, @params)
        {:ok, ^uuid} = Ecto.UUID.load(raw)
      end
    end

    test "cast/2 rejects invalid input" do
      assert Prefixed.cast(nil, @params) == {:ok, nil}
      assert Prefixed.cast("otherprefix_F6tzXELwufrXBFtFTKsUvc", @params) == :error
      assert Prefixed.cast("tst_" <> String.duplicate(".", 32), @params) == :error
    end

    test "cast/2 resolves belongs_to prefix" do
      slug = Prefixed.autogenerate(@params)
      assert Prefixed.cast(slug, @belongs_to_params) == {:ok, slug}
    end

    test "load/3 roundtrips through dump/3" do
      check all(uuid <- ShortUUID.Generators.uuid()) do
        raw = Ecto.UUID.dump!(uuid)
        {:ok, slug} = Prefixed.load(raw, @loader, @params)
        {:ok, ^raw} = Prefixed.dump(slug, @dumper, @params)
      end
    end

    test "load/3 rejects invalid input" do
      assert Prefixed.load(nil, @loader, @params) == {:ok, nil}
      assert Prefixed.load(String.duplicate(".", 22), @loader, @params) == :error
      assert Prefixed.load("tst_F6tzXELwufrXBFtFTKsUvc", @loader, @params) == :error
    end

    test "dump/3 rejects invalid input" do
      assert Prefixed.dump(nil, @dumper, @params) == {:ok, nil}
      raw = Ecto.UUID.dump!(Ecto.UUID.generate())
      assert Prefixed.dump(raw, @dumper, @params) == :error
    end

    test "autogenerate/1 produces valid slugs" do
      slug = Prefixed.autogenerate(@params)
      assert "tst_" <> _ = slug
      {:ok, raw} = Prefixed.dump(slug, @dumper, @params)
      {:ok, _uuid} = Ecto.UUID.load(raw)
    end

    test "to_uuid/1 roundtrips" do
      check all(uuid <- ShortUUID.Generators.uuid()) do
        {:ok, slug} = Prefixed.cast(uuid, @params)
        assert Prefixed.to_uuid(slug) == {:ok, uuid}
      end
    end

    test "to_uuid/1 rejects invalid input" do
      assert Prefixed.to_uuid("invalid") == :error
    end
  end
end
