defmodule Chap10.EagerVsLazy do
  import Enum, only: [filter: 2, map: 2, sum: 1]

  @doc """
  All the functions in the Enum module are eager.
  Many functions expect an enumerable and return a list back:

  This means that when performing multiple operations with Enum,
  each operation is going to generate an intermediate list
  until we reach the result:
  """
  def multiple_sum_odds(values) do
    values
      |> map(&(&1 * 3))
      |> filter(&(odd?/1))
      |> sum
  end

  def filter_test(values) do
    filter(values, &(odd?/1))
  end

  defp odd?(value) do
    rem(value, 2) != 0
  end
end
