defprotocol Size do
  @doc "Calculates the size (and not the length!) of a data structure"
  def size(data)
end

# example 1

defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end

# example 2 - use w/ struct 1

defimpl Size, for: MapSet do
  def size(set), do: MapSet.size(set)
end

# example 3 - use w/ struct 2

defmodule User do
  defstruct [:name, :age]
end

defimpl Size, for: User do
  def size(_user), do: 2
end

# example 4 - use Ant

defimpl Size, for: Any do
  def size(_), do: 0
end
