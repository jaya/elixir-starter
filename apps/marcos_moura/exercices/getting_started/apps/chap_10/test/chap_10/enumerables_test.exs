defmodule Chap10.EnumerablesTest do
  use ExUnit.Case
  doctest Chap10.Enumerables

  import Chap10.Enumerables, only: [map_test: 1, map_reduce: 1]

  test "map" do
    assert map_test(1..3) == [2, 4, 6]
  end

  test "map reduce" do
    assert map_reduce(1..4) == 10
  end
end

