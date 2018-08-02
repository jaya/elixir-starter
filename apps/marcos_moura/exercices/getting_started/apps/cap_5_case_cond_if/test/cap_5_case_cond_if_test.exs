defmodule Cap5CaseCondIfTest do
  use ExUnit.Case
  doctest Cap5CaseCondIf

  test "case match" do
    assert Cap5CaseCondIf.match({1, 2, 3}) == "This clause will match and bind _ to any value in this clause"
  end

  test "won't match against a var" do
    assert Cap5CaseCondIf.match_against_var(10) == "Won't match"
  end

  test "will match against a var" do
    assert Cap5CaseCondIf.match_against_var(1) == "Will match"
  end
end
