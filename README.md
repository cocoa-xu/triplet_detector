# TripletDetector

Detecting current node's triplet `ARCH-OS-ABI` in pure Elixir. Not depending on external programs like `uname` or need a C compiler.

The following triplet can be detected:

### macOS
- x86_64-apple-darwin
- arm64-apple-darwin

### Linux GNU libc
- x86_64-linux-gnu
- aarch64-linux-gnu
- arm-linux-gnueabihf
- riscv64-linux-gnu
- s390x-linux-gnu
- powerpc64le-linux-gnu

### Linux musl libc
- x86_64-linux-musl
- aarch64-linux-musl
- aarch64_be-linux-musl
- armv7l-linux-musleabihf
- armv7m-linux-musleabi
- armv7r-linux-musleabihf
- riscv32-linux-musl
- riscv64-linux-musl
- powerpc64le-linux-musl

## Example
```elixir
# For a Mac with Apple Silicon, `ARCH-OS-ABI` is `arm64-darwin-darwin`.
{:ok, "arm64-darwin-darwin"} = TripletDetector.detect()
"arm64-darwin-darwin" = TripletDetector.detect!()

# For Linux with ARMv7, `ARCH-OS-ABI` is `arm-linux-gnueabihf`.
{:ok, "arm-linux-gnueabihf"} = TripletDetector.detect()
"arm-linux-gnueabihf" = TripletDetector.detect!()

# If the current node is not supported, `ARCH-OS-ABI` is `unknown`.
{:error, "unknown"} = TripletDetector.detect()
"unknown" = TripletDetector.detect!()
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `triplet_detector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:triplet_detector, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/triplet_detector>.

