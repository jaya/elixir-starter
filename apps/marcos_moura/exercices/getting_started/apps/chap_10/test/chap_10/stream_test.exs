defmodule Chap10.StreamTest do
  use ExUnit.Case
  doctest Chap10.Stream

  import Chap10.Stream, only: [multiple_sum_odds: 1]

  test "multiple and sum only odd results" do
    assert multiple_sum_odds(1..3) == 12
  end
end


