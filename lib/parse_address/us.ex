defmodule ParseAddress.US do
  @moduledoc """
  ParseAddress is a regex-based street address and street intersection parser for the United States. Its
  basic goal is to be as forgiving as possible when parsing user-provided address strings. ParseAddress
  knows about directional prefixes and suffixes, fractional building numbers, building units, grid-based
  addresses (such as those used in parts of Utah), 5 and 9 digit ZIP codes, and all of the official USPS
  abbreviations for street types, state names and secondary unit designators.

  """

  alias ParseAddress.US.{State, Street}

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
    :type    => Street.street_type(),
    :type1   => Street.street_type(),
    :type2   => Street.street_type(),
    :state   => State.state_code(),
  }

  @addr_match_type Street.street_type_list() |> Enum.join("|") |> Regex.compile!()

  @addr_match_fraction ~r/\d+\/\d+/
  
  @addr_match_state Regex.compile!("
    \\b(?:" <>
    (State.state_code() |> Map.keys |> Enum.join("|")) <>
    "|" <>
    (State.state_code() |> Map.values |> Enum.join("|")) <>
    ")\\b", "ix")

  @addr_match_direct @directional |> Map.keys |> Enum.concat(Map.values(@directional)) |> Enum.join("|") |> Regex.compile!()

  @addr_match_dircode @direction_code |> Map.keys |> Enum.join("|") |> Regex.compile!

  @addr_match_zip ~r/\d{5}(?:-?\d{4})?/

  @addr_match_corner ~r/(?:\band\b|\bat\b|&|\@)/
  
  @addr_match_number Regex.compile!("(?<number>\\d+-?\\d*)(?=\\D)", "ix")

  @addr_match_street Regex.compile!("
      (?:
        (?:(?<street_0>" <> @addr_match_direct.source <> ")\\W+
           (?<type_0>" <> @addr_match_type.source <> ")\\b
        )
        |
        (?:(?<prefix_0>" <> @addr_match_direct.source <> ")\\W+)?
        (?:
          (?<street_1>[^,]*\\d)
          (?:[^\\w,]*(?<suffix_1>" <> @addr_match_direct.source <> ")\\b)
          |
          (?<street_2>[^,]+)
          (?:[^\\w,]+(?<type_2>" <> @addr_match_type.source <> ")\\b)
          (?:[^\\w,]+(?<suffix_2>" <> @addr_match_direct.source <> ")\\b)?
          |
          (?<street_3>[^,]+?)
          (?:[^\\w,]+(?<type_3>" <> @addr_match_type.source <> ")\\b)?
          (?:[^\\w,]+(?<suffix_3>" <> @addr_match_direct.source <> ")\\b)?
        )
        )", "ix")

  @addr_match_sec_unit_type_numbered Regex.compile!("
      (?<sec_unit_type_1>su?i?te
        |p\\W*[om]\\W*b(?:ox)?
        |(?:ap|dep)(?:ar)?t(?:me?nt)?
        |ro*m
        |flo*r?
        |uni?t
        |bu?i?ldi?n?g
        |ha?nga?r
        |lo?t
        |pier
        |slip
        |spa?ce?
        |stop
        |tra?i?le?r
        |box)(?![a-z]
        )", "ix")

  @addr_match_sec_unit_type_unnumbered Regex.compile!("
      (?<sec_unit_type_2>ba?se?me?n?t
        |fro?nt
        |lo?bby
        |lowe?r
        |off?i?ce?
        |pe?n?t?ho?u?s?e?
        |rear
        |side
        |uppe?r
        )\\b", "ix")

  @addr_match_sec_unit Regex.compile!("
      (?:
        (?:
          (?:
            (?:" <> @addr_match_sec_unit_type_numbered.source <> "\\W*)
            |(?<sec_unit_type_3>\\#)\\W*
          )
          (?<sec_unit_num_1>[\\w-]+)
        )
        |
        " <> @addr_match_sec_unit_type_unnumbered.source <> ")",
    "ix")

  @addr_match_city_and_state Regex.compile!("
      (?:
        (?<city>[^\\d,]+?)\\W+
        (?<state>" <> @addr_match_state.source <> ")
        )", "ix")

  @addr_match_place Regex.compile!("
      (?:" <> @addr_match_city_and_state.source <> "\\W*)?
      (?:(?<zip>" <> @addr_match_zip.source <> "))?", "ix")

  @addr_match_address Regex.compile!("
      ^
      [^\\w\\#]*
      (" <> @addr_match_number.source <> ")\\W*
      (?:" <> @addr_match_fraction.source <> "\\W*)?
         " <> @addr_match_street.source <> "\\W+
      (?:" <> @addr_match_sec_unit.source <> ")?\\W*
      " <> @addr_match_place.source <> "
      \\W*$", "ix")

  @addr_match_sep ~r/(?:\W+|\Z)/

  @addr_match_informal_address Regex.compile!("
      ^
      \\s*
      (?:" <> @addr_match_sec_unit.source <> @addr_match_sep.source <> ")?
      (?:" <> @addr_match_number.source <> ")?\\W*
      (?:" <> @addr_match_fraction.source <> "\\W*)?
      " <> @addr_match_street.source <> @addr_match_sep.source <> "
      (?:" <> (@addr_match_sec_unit.source |> String.replace(~r/_(\d)/, "__\\1")) <> @addr_match_sep.source <> ")?
      (?:" <> @addr_match_place.source <> ")?
      ", "ix")

  @addr_match_intersection Regex.compile!("
      ^\\W*
      " <> (@addr_match_street.source |> String.replace(~r/_(\d)/, "__\\1")) <> "\\W*?
      \\s+" <> @addr_match_corner.source <> "\\s+
      " <> (@addr_match_street.source |> String.replace(~r/_(\d)/, "___\\1")) <> "\\W+
      " <> @addr_match_place.source <> "\\W*$", "ix")
  
  @doc """
  Parses any address or intersection string and returns the appropriate specifier. If `location` matches the
  `corner` pattern then `parse_intersection/1` is used. Else `parse_address/1` is called and if that returns
  a failure then `parse_informal_address/1` is called.

  """
  @spec parse_location(address :: binary) :: :none | Address.t
  def parse_location(""), do: :none
  def parse_location(address) do
    parsed = parse_address(address)
    IO.inspect(parsed)
    
    cond do
      Regex.match?(@addr_match_corner, address) ->
        parse_intersection(address)

      parsed != :none ->
        parsed
      
      true -> parse_informal_address(address) 
    end
  end

  @doc """
  Parses an intersection string into an intersection specifier, returning `:error` if the address cannot
  be parsed. You probably want to use `parse_location/1` instead.

  """
  def parse_intersection(address) do
    parts = Regex.named_captures(@addr_match_intersection, address)
    parts = normalize_address(parts)

    case parts do
      :none -> :none
      _ ->
        %Address{parts |
                 type1: (if parts.type1 == nil, do: "", else: parts.type1),
                 type2: (if parts.type2 == nil, do: "", else: parts.type2)
                }
    end
  end

  @doc """
  Parses a street address into an address specifier using the `address` pattern. Returning :error if
  the address cannot be parsed as a complete formal address.

  You may want to use `parse_location/1` instead.

  """
  @spec parse_address(address :: binary) :: Address.t | :none
  def parse_address(address) do
    parts = Regex.named_captures(@addr_match_address, address)
    IO.inspect(parts)
    case parts do
      nil -> :none
      _ -> 
        case Enum.empty?(parts) do
          true  -> :none
          false -> normalize_address(parts)
        end
    end
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
    parts = Regex.named_captures(@addr_match_informal_address, address)
    case parts do
      nil -> :none
      _ ->
        case Enum.empty?(parts) do
          true -> :none
          false -> normalize_address(parts)
        end
    end
  end

  @doc """
  Takes an address or intersection specifier, and normalizes its components, stripping out all
  leading and trailing whitespace and punctuation, and substituting official abbreviations for
  prefix, suffix, type, and state values. Also, city names that are prefixed with a directional
  abbreviation (e.g. N, NE, etc.) have the abbreviation expanded.  The original specifier ref
  is returned.

  Converts the raw `Map` into a `ParseAddress.Address.t` 

  Typically, you won't need to use this method, as the `parse_` methods call it for you.

  This modified from the original Perl implementation so that it does not strip out the second
  half of nine-digit zip codes.

  """
  @spec normalize_address(parts :: map) :: Address.t
  def normalize_address(parts = %{}) do
    IO.inspect(parts)
    address = %Address{
      country: "United States of America",
      state: clean(parts, "state"),
      city: clean(parts, "city"),
      zip: clean(parts, "zip"),
      number: clean(parts, "number"),
      street: clean(parts, "street_2"),
      prefix: clean(parts, "prefix_0"),
      type: clean(parts, "type_2"),
      suffix: clean(parts, "suffix_2"),
      sec_unit_num: clean(parts, "sec_unit_num_1"),
      sec_unit_type: clean(parts, "sec_unit_type_1"),

      intersecting: clean(parts, "street__3"),
    }

    inter1 = clean(parts, "street___2")
    inter2 = clean(parts, "street__3")
    alt = if inter2 != nil, do: inter2, else: clean(parts, "street_3")
    address = %Address{address |
                       street: (if alt != nil, do: alt, else: address.street)}
    address = %Address{address |
                       intersecting: (if inter1 != nil, do: inter1, else: address.street)}
    address
  end

  defp clean(parts, field) do
    val = Map.get(parts, field, nil)
    if val == "", do: nil, else: val
  end
end
