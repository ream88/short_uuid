# ShortUUID [![CI](https://github.com/ream88/short_uuid/actions/workflows/elixir.yml/badge.svg)](https://github.com/ream88/short_uuid/actions/workflows/elixir.yml)

<!-- MDOC !-->

Encode and decode [UUIDs](https://en.wikipedia.org/wiki/Universally_unique_identifier) into a shorter [Base58](https://github.com/bitcoin/bitcoin/blob/08a7316c144f9f2516db8fa62400893f4358c5ae/src/base58.h#L6-L13) representation.

```elixir
iex> ShortUUID.encode("64d7280f-736a-4ffa-b9c0-383f43486d0b")
{:ok, "DTEETeS5R2XxjrVTZxXoJS"}

iex> ShortUUID.decode("DTEETeS5R2XxjrVTZxXoJS")
{:ok, "64d7280f-736a-4ffa-b9c0-383f43486d0b"}
```

## Prefixed IDs (Ecto)

With [Ecto](https://hex.pm/packages/ecto) installed, `ShortUUID.Prefixed` provides Stripe-style prefixed IDs as an Ecto parameterized type. UUIDs are stored as-is in the database, prefixed ShortUUIDs are used in your application:

```elixir
defmodule MyApp.User do
  use ShortUUID.Prefixed.Schema, prefix: "usr"

  schema "users" do
  end
end

user = Repo.get!(User, "usr_F6tzXELwufrXBFtFTKsUvc")
user.id #=> "usr_F6tzXELwufrXBFtFTKsUvc"
```

See `ShortUUID.Prefixed` docs for helpers and manual schema setup.

<!-- MDOC !-->

## Installation

```elixir
def deps do
  [
    {:short_uuid, "~> 3.0"}
  ]
end
```

## License

[MIT](./LICENSE)
