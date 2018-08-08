defmodule Chap10.Stream do
  def multiple_sum_odds(values) do
    values
    |> Stream.map(&(&1 * 3))
    |> Enum.sum
  end
end
