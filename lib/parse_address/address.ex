defmodule Address do
  @type t :: %__MODULE__{
    country:       binary,
    state:         binary,
    city:          binary,
    zip:           binary,
    number:        binary,
    prefix:        binary,
    type:          binary,
    suffix:        binary,
    sec_unit_type: binary,
    sec_unit_num:  binary,

    # the following are used only when an intersection is detected 
    prefix1:       binary,
    prefix2:       binary,
    type1:         binary,
    type2:         binary,
    suffix1:       binary,
    suffix2:       binary,
  }

  defstruct [
    country: nil,
    state: nil,
    city: nil,
    zip: nil,
    number: nil,
    prefix: nil,
    type: nil,
    suffix: nil,
    sec_unit_type: nil,
    sec_unit_num: nil,
    prefix1: nil,
    prefix2: nil,
    type1: nil,
    type2: nil,
    suffix1: nil,
    suffix2: nil
  ]
end
