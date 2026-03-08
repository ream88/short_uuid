# Changelog

## 3.0.0

### Breaking

- `ShortUUID.encode/1` and `ShortUUID.decode/1` now return `:error` instead of `{:error, :invalid_uuid}`

### Added

- `ShortUUID.Prefixed` — Ecto parameterized type for Stripe-style prefixed IDs (e.g., `usr_F6tzXELwufrXBFtFTKsUvc`)
- `ShortUUID.Prefixed.Schema` — convenience macro for setting up Ecto schemas
- `ShortUUID.Prefixed.to_uuid/1` and `ShortUUID.Prefixed.to_uuid!/1` — convert prefixed IDs back to UUIDs
- Ecto as optional dependency

### Changed

- Repository moved to [ream88/short_uuid](https://github.com/ream88/short_uuid)
- Loosened `ex_doc` and `stream_data` version requirements

## 2.1.1

- Improved docs and type specs

## 2.1.0

- Added `ShortUUID.encode!/1` and `ShortUUID.decode!/1` bang variants

## 2.0.0

- Input validation and friendly error output
- Property-based tests with `stream_data`

## 1.0.0

- Initial release
- Base58 encoding/decoding of UUIDs
