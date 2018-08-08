defmodule Chap10.EagerVsLazyTest do
  use ExUnit.Case
  doctest Chap10.EagerVsLazy

  import Chap10.EagerVsLazy, only: [filter_test: 1, multiple_sum_odds: 1]

  test "filter" do
    assert filter_test(1..3) == [1, 3]
  end

  test "multiple and sum only odd results" do
    assert multiple_sum_odds(1..3) == 12
  end
end
