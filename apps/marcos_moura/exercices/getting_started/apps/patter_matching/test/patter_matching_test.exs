defmodule PatterMatchingTest do
  use ExUnit.Case
  doctest PatterMatching

  test "ok matching on tuples" do
    assert PatterMatching.ok({:ok, 13}) == {:ok, 13}
  end

  test "error matching" do
    assert_raise MatchError, fn -> PatterMatching.ok({:error, 13}) == {:ok, 13} end
  end

  test "head match" do
    assert PatterMatching.head([1, 2, 3]) == 1
  end

  test "tail match" do
    assert PatterMatching.tail([1, 2, 3]) == [2, 3]
  end

  test "prepend to list" do
    assert PatterMatching.prepend(0, [1, 2, 3]) == [0, 1, 2, 3]
  end

  test "rebind success" do
    assert PatterMatching.rebind(1) == 1
  end

  test "rebind fail" do
    assert_raise MatchError, fn -> PatterMatching.rebind(2) end
  end

  test "rebind tuple success" do
    assert PatterMatching.rebind_tuple(1) == {2, 1}
  end

  test "rebind tuple fail" do
    assert_raise MatchError, ~r/./, fn -> PatterMatching.rebind_tuple(2) end
  end

  test "ignore values" do
    assert PatterMatching.ignore({1, 2, 3}) == {1, 2}
  end
end
