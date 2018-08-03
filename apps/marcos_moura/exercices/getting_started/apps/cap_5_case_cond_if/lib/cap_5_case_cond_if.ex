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
      ^x -> "Will match"
      _ -> "Won't match"
    end
  end

  def match_with_when(tuple) do
    case tuple do
      {1, x, 3} when  x > 10 -> "Will match"
      _ -> "Won't match"
    end
  end

  def match_error do
    case 1 do
      0 -> "never match"
    end
  end

  @doc """
    iex> Cap5CaseCondIf.cond(4)
    "This will be seven"

    iex> Cap5CaseCondIf.cond(2)
    "This will be four"

    iex> Cap5CaseCondIf.cond(3)
    "This will be three"

    iex> Cap5CaseCondIf.cond(1)
    "This will be 1"
  """
  def cond(value) do
    cond do
      4 + 3 == value + 3 -> "This will be seven"
      2 * 2 == value * 2-> "This will be four"
      1 + 2 == value -> "This will be three"
      true -> "This will be #{value}"
    end
  end

  @doc """
  if/2 using keyword list

  iex> Cap5CaseCondIf.if_else(true)
  :this

  iex> Cap5CaseCondIf.if_else(false)
  :that
  """
  def if_else(bool) do
    if bool, do: :this, else: :that
  end

  @doc """
  if/2 keyword list with multiple statements

  iex> Cap5CaseCondIf.if_keyword_list(2)
  4

  iex> Cap5CaseCondIf.if_keyword_list(1)
  nil
  """
  def if_keyword_list(value) do
    if value == 2, do: (
      a = value - 1
      a + 3
    )
  end
end
