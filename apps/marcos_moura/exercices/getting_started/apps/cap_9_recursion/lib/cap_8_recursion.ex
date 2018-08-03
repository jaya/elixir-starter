defmodule Cap8Recursion do
  @moduledoc """
  In imperative language the loop with for mutate the
  array and the variable i, as
  >for(i = 0; i < sizeof(array), i++)

  But in functional language mutation is not possible
  we use recursion instead

  The recursion loop untils it reaches the stop or
  some condition

  No data is mutate in this process
  """

  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts(msg)
  end

  def print_multiple_times(msg, n) do
    IO.puts(msg)
    print_multiple_times(msg, n - 1)
  end

  @doc """
  calls recursively this method until there is a empty list as params

  This is a reducing altorithm, wich we are taking values one by one from a list

  iex> Cap8Recursion.sum_list([1 | [2 | [3 | [] ]]], 0)
  6

  iex> Cap8Recursion.sum_list([1 | []], 10)
  11
  """
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator), do: accumulator

  @doc """
  when the param is a empty list the double_list is not call anymore and the
  recursion ends

  This is a map algorithm, it takes a list and map over it
  """
  def double_list([]), do: []

  def double_list([head | tail]) do
    [head * 2 | double_list(tail)]
  end
end
