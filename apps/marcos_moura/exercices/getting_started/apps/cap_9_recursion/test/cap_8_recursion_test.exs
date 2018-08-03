defmodule Cap8RecursionTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Cap8Recursion

  setup do
    {:ok, str: "ola"}
  end

  describe "recursion" do
    test "one loop", context do
      assert capture_io(fn -> Cap8Recursion.print_multiple_times(context[:str], 1) end) == "ola\n"
    end

    test "two loop", context do
      assert capture_io(fn -> Cap8Recursion.print_multiple_times(context[:str], 2) end) ==
        "ola\nola\n"
    end

    test "receive :ok", context do
      capture_io(fn ->
        send(self(), Cap8Recursion.print_multiple_times(context[:str], 2))
      end)

      assert_received :ok
    end
  end

  describe "Reduce and map" do
    test "sum of a list" do
      assert Cap8Recursion.sum_list([1, 2, 3], 0) == 6
    end

    test "double values of the list" do
      assert Cap8Recursion.double_list([1, 2, 3, 4]) == [2, 4, 6, 8]
    end
  end
end
