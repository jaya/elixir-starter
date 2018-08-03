defmodule Cap5CaseCondIfTest do
  use ExUnit.Case
  doctest Cap5CaseCondIf

  test "case match" do
    assert Cap5CaseCondIf.match({1, 2, 3}) == "This clause will match and bind _ to any value in this clause"
  end

  test "won't match against one" do
    assert Cap5CaseCondIf.match_against_var(10) == "Won't match"
  end

  test "will match against one" do
    assert Cap5CaseCondIf.match_against_var(1) == "Will match"
  end

  test "will match with when" do
    assert Cap5CaseCondIf.match_with_when({1, 12, 3}) == "Will match"
  end

  test "when won't match" do
    assert Cap5CaseCondIf.match_with_when({1, 9, 3}) == "Won't match"
  end

  test "case clause error" do
    assert_raise CaseClauseError, fn -> Cap5CaseCondIf.match_error() end
  end

  test "condition clause" do
    assert Cap5CaseCondIf.cond(3) == "This will be three"
  end
end
