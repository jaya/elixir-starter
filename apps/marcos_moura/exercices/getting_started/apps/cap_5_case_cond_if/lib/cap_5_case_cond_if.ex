defmodule Cap5CaseCondIf do
  @moduledoc """
  Documentation for Cap5CaseCondIf.
  """

  @doc """
    iex> Cap5CaseCondIf.match({4, 5, 6})
    "This clause won't match"

    iex> Cap5CaseCondIf.match({1, 7, 3})
    "This clause will match and bind _ to any value in this clause"

    iex> Cap5CaseCondIf.match(1)
    "This clause would match any value"
  """
  def match(tuple) do
    case tuple do
      {4, 5, 6} ->
        "This clause won't match"
      {1, _, 3} ->
        "This clause will match and bind _ to any value in this clause"
      _ ->
        "This clause would match any value"
    end
  end

  def match_against_var(value) do
    x = 1
    case value do
      ^x -> "Won't match"
      _ -> "Will match"
    end
  end
end
