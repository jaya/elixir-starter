defmodule Chap10.Enumerables do
  import Enum, only: [map: 2, reduce: 3]

  def map_test(x) do
    map(x, fn x -> x * 2 end)
  end

  def map_reduce(values) do
    reduce(values, 0, &+/2)
  end
end
