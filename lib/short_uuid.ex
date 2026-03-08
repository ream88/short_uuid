defmodule ShortUUID do
  import ShortUUID.Guards

  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @abc ["1", "2", "3", "4", "5", "6", "7", "8", "9"] ++
         ["A", "B", "C", "D", "E", "F", "G", "H"] ++
         ["J", "K", "L", "M", "N"] ++
         ["P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] ++
         ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"] ++
         ["m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

  @abc_length Enum.count(@abc)

  @typedoc "A standard UUID string, e.g. `\"64d7280f-736a-4ffa-b9c0-383f43486d0b\"`."
  @type uuid :: binary()

  @typedoc "A Base58-encoded UUID, e.g. `\"DTEETeS5R2XxjrVTZxXoJS\"`."
  @type short_uuid :: binary()

  @doc """
  Encodes the given UUID into a ShortUUID.

  Returns `{:ok, short_uuid}` on success, `:error` on invalid input.

  ## Examples

      iex> ShortUUID.encode("64d7280f-736a-4ffa-b9c0-383f43486d0b")
      {:ok, "DTEETeS5R2XxjrVTZxXoJS"}

      iex> ShortUUID.encode("invalid-uuid-here")
      :error

  """
  @spec encode(uuid()) :: {:ok, short_uuid()} | :error
  def encode(input) when is_uuid(input) do
    input
    |> String.replace("-", "")
    |> String.to_integer(16)
    |> encode("")
  end

  def encode(_), do: :error

  defp encode(input, output) when input > 0 do
    index = rem(input, @abc_length)
    input = div(input, @abc_length)
    output = "#{Enum.at(@abc, index)}#{output}"

    encode(input, output)
  end

  defp encode(0, output), do: {:ok, output}

  @doc """
  Encodes the given UUID into a ShortUUID.

  Raises `ArgumentError` on invalid input.

  ## Examples

      iex> ShortUUID.encode!("64d7280f-736a-4ffa-b9c0-383f43486d0b")
      "DTEETeS5R2XxjrVTZxXoJS"

  """
  @doc since: "2.1.0"
  @spec encode!(uuid()) :: short_uuid()
  def encode!(input) do
    case encode(input) do
      {:ok, result} -> result
      :error -> raise ArgumentError
    end
  end

  @doc """
  Decodes the given ShortUUID back into a UUID.

  Returns `{:ok, uuid}` on success, `:error` on invalid input.

  ## Examples

      iex> ShortUUID.decode("DTEETeS5R2XxjrVTZxXoJS")
      {:ok, "64d7280f-736a-4ffa-b9c0-383f43486d0b"}

      iex> ShortUUID.decode("DTEETeS5R2XxjrVTZxXoJS123")
      :error

      iex> ShortUUID.decode("InvalidShortUUID")
      :error

  """
  @spec decode(short_uuid()) :: {:ok, uuid()} | :error
  def decode(input) when is_binary(input) do
    codepoints = String.codepoints(input)

    unless Enum.all?(codepoints, &(&1 in @abc)) do
      :error
    else
      codepoints
      |> Enum.reduce(0, fn codepoint, acc ->
        acc * @abc_length + Enum.find_index(@abc, &(&1 == codepoint))
      end)
      |> Integer.to_string(16)
      |> String.pad_leading(32, "0")
      |> String.downcase()
      |> format()
    end
  end

  @doc """
  Decodes the given ShortUUID back into a UUID.

  Raises `ArgumentError` on invalid input.

  ## Examples

      iex> ShortUUID.decode!("DTEETeS5R2XxjrVTZxXoJS")
      "64d7280f-736a-4ffa-b9c0-383f43486d0b"

  """
  @doc since: "2.1.0"
  @spec decode!(short_uuid()) :: uuid()
  def decode!(input) do
    case decode(input) do
      {:ok, result} -> result
      :error -> raise ArgumentError
    end
  end

  defp format(<<a::64, b::32, c::32, d::32, e::96>>) do
    {:ok, <<a::64, ?-, b::32, ?-, c::32, ?-, d::32, ?-, e::96>>}
  end

  defp format(_), do: :error
end
