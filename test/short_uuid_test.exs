defmodule ShortUUIDTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest ShortUUID

  test "encode/1" do
    check all(uuid <- ShortUUID.Generators.uuid()) do
      assert uuid == ShortUUID.decode!(ShortUUID.encode!(uuid))
    end
  end

  test "encode!/1 raises on error" do
    assert_raise ArgumentError, fn ->
      ShortUUID.encode!("invalid-uuid-here")
    end
  end

  test "decode!/1 raises on error" do
    assert_raise ArgumentError, fn ->
      ShortUUID.decode!("DTEETeS5R2XxjrVTZxXoJS123")
    end

    assert_raise ArgumentError, fn ->
      ShortUUID.decode!("InvalidShortUUID")
    end
  end
end
