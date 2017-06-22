defmodule ParseAddressTest do
  use ExUnit.Case
  doctest ParseAddress

  alias ParseAddress

  test "a simple address" do
    matches?("500 W 56th St, Apt 522, New York, NY 10019",
      %{city: "New York", state: "NY", zip: "10019", number: "500"})    
  end

  test "a street address" do
    matches?("1400 Broadway",
      %{street: "Broadway", number: "1400"})
  end

  test "an intersection with city" do
    matches?("Broadway and Spring St, New York, NY",
      %{street: "Broadway", intersecting: "Spring", city: "New York", state: "NY"})
  end

  test "a longer zip code" do
    matches?("4405 STARKEY ROAD, SUITE B ROANOKE VA 24011-1914 US",
      %{number: "4405", street: "STARKEY", state: "VA", city: "ROANOKE",
        zip: "24011-1914"})
  end

  test "street and suite only" do
    matches?("1274 49 Street - Suite 117",
      %{number: "1274", street: "49 Street", sec_unit_type: "Suite", sec_unit_num: "117"})
  end

  test "street and nameless unit" do
    matches?("123 Bedford Avenue 456",
      %{number: "123", street: "Bedford Avenue", sec_unit_num: "456"})
  end

  test "comma-free address" do
    matches?("200 MADISON AVENUE 5TH FL NEW YORK NY 10016",
      %{number: "200", street: "MADISON AVENUE", sec_unit_type: "FL", sec_unit_num: "5TH",
        city: "NEW YORK", state: "NY", zip: "10016"})
  end
 
  @doc """
  For every non-nil property in the `compare` parameter, check to make sure that its value
  matches the value set in the processed version of `address`.
  """
  defp matches?(address, compare) do
    result = ParseAddress.parse(address)

    Enum.each(Map.keys(compare), fn key ->
      assert Map.get(result, key) == Map.get(compare, key)
    end)
  end
end
