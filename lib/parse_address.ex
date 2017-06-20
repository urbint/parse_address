defmodule ParseAddress do
  @moduledoc """
  ParseAddress is a regex-based street address and street intersection parser for the United States. Its
  basic goal is to be as forgiving as possible when parsing user-provided address strings. ParseAddress
  knows about directional prefixes and suffixes, fractional building numbers, building units, grid-based
  addresses (such as those used in parts of Utah), 5 and 9 digit ZIP codes, and all of the official USPS
  abbreviations for street types, state names and secondary unit designators.

  """

  alias ParseAddress.{State, Street}

  @doc """
  Maps directional names (north, northeast, etc.) to abbreviations (N, NE, etc.).

  """
  @directional %{
    "north"     => "N",
    "northeast" => "NE",
    "east"      => "E",
    "southeast" => "SE",
    "south"     => "S",
    "southwest" => "SW",
    "west"      => "W",
    "northwest" => "NW",
  }

  @direction_code Enum.reduce(@directional, %{}, fn {k, v}, acc -> Map.merge(acc, %{v => k}) end)

  @normalize_map %{
    :prefix  => @directional,
    :prefix1 => @directional,
    :prefix2 => @directional,
    :suffix  => @directional,
    :suffix1 => @directional,
    :suffix2 => @directional,
    :type    => @street_type,
    :type1   => @street_type,
    :type2   => @street_type,
    :state   => @state_code
  }

  @addr_match %{
    :type => Module.get_attribute(Street, :street_type_list) |> Enum.join("|") |> Regex.compile!(),
    :fraction => ~r(\d+\/\d+),
    :state => Regex.compile!("\b(?:" <>
      Module.get_attribute(State, :state_code) |> Map.keys |> Enum.join("|") <>
      "|" <>
      Module.get_attribute(State, :state_code) |> Map.values |> Enum.join("|")
    ),
  }

  @doc """
  Parses any address or intersection string and returns the appropriate specifier. If `location` matches the
  `corner` pattern then `parse_intersection/1` is used. Else `parse_address/1` is called and if that returns
  a failure then `parse_informal_address/1` is called.

  """
  def parse_location(location) do
    cond do
      location == "" -> :none
      true -> location
    end
  end

  @doc """
  Parses an intersection string into an intersection specifier, returning `:error` if the address cannot
  be parsed. You probably want to use `parse_location/1` instead.

  """
  def parse_intersection(intersection) do
  end

  @doc """
  Parses a street address into an address specifier using the `address` pattern. Returning :error if
  the address cannot be parsed as a complete formal address.

  You may want to use `parse_location/1` instead.

  """
  def parse_address(address) do
  end

  @doc """
  Acts like `parse_address/1` except that it handles a wider range of address formats because it
  uses the `informal_address` pattern. That means a unit can come first, a street number is optional,
  and the city and state aren't needed. Which means that informal addresses like "#42 123 Main St"
  can be parsed.

  Returns `:error` if the address cannot be parsed.

  You may want to use `parse_location/1` instead.  

  """
  def parse_informal_address(address) do
  end

  @doc """
  Takes an address or intersection specifier, and normalizes its components, stripping out all
  leading and trailing whitespace and punctuation, and substituting official abbreviations for
  prefix, suffix, type, and state values. Also, city names that are prefixed with a directional
  abbreviation (e.g. N, NE, etc.) have the abbreviation expanded.  The original specifier ref
  is returned.

  Typically, you won't need to use this method, as the `parse_` methods call it for you.

  This modified from the original Perl implementation so that it does not strip out the second
  half of nine-digit zip codes.

  """
  def normalize_address(address) do
  end
end
