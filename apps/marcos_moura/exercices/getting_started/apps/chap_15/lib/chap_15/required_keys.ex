defmodule Chap15.RequiredKeys do
  @enforce_keys [:make]
  defstruct [:model, :make]
end
