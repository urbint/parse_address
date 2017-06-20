defmodule ParseAddress do
  @moduledoc """
  ParseAddress is a regex-based street address and street intersection parser for the United States. Its
  basic goal is to be as forgiving as possible when parsing user-provided address strings. ParseAddress
  knows about directional prefixes and suffixes, fractional building numbers, building units, grid-based
  addresses (such as those used in parts of Utah), 5 and 9 digit ZIP codes, and all of the official USPS
  abbreviations for street types, state names and secondary unit designators.

  """

  alias ParseAddress.Address
  alias ParseAddress.US

  @doc """
  Parses any address or intersection string and returns the appropriate specifier.

  Relies on individual implementations for different country groups. Currently only supports
  the United States (:us)

  """
  @spec parse(binary, atom) :: :none | :invalid_country | Address.t
  def parse(text, :us), do: US.parse_location(text)
  def parse(_, _), do: :invalid_country
end
