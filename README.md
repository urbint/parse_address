# ParseAddress

This is a port of the epic Perl CPAN package Geo::StreetAddress::US library (http://search.cpan.org/~timb/Geo-StreetAddress-US-1.04/US.pm)
with a huge amount of thanks to @hassansin for his JavaScript port (https://github.com/hassansin/parse-address) which we used for guidance
during the port.

This library takes a string that is either a full address, or a snippet of an address and does it's best to extract whatever fields it can
from the string. It includes support for intersection style addresses (e.g. Broadway & 6th Avenue) as well as a lot of other odd
variations that have shown up in our data set. The only changes to the matching from the original Perl implementation was to enhance the
ability to match "-" and "/" in the street number portion of the address to support a number of addresses we see around the New York City
area.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `parse_address` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:parse_address, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/parse_address](https://hexdocs.pm/parse_address).

