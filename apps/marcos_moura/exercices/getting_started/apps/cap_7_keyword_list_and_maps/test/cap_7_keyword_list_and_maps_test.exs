defmodule Cap7KeywordListAndMapsTest do
  use ExUnit.Case
  doctest Cap7KeywordListAndMaps

  test "simple keyword list" do
    assert Cap7KeywordListAndMaps.list_default_notation() == [a: "a", b: "b"]
  end

  test "special syntax notation to list" do
    assert Cap7KeywordListAndMaps.list_special_notation() == [a: "a", b: "b"]
  end

  test "append to list" do
   assert Cap7KeywordListAndMaps.append([c: 3], [a: 1, b: 2]) == [a: 1, b: 2, c: 3]
  end

  test "prepend to list" do
    assert Cap7KeywordListAndMaps.prepend([a: 1], b: 2, c: 3) == [a: 1, b: 2, c: 3]
  end

  test "get first" do
    assert Cap7KeywordListAndMaps.get(:a, [a: 1, a: 2, b: 2]) == 1
  end
end
