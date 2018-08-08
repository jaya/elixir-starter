defmodule Cap8ModulesAndFunctions do
  @moduledoc """
  Documentation for Cap8ModulesAndFunctions.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cap8ModulesAndFunctions.zero? 0
      true

  """
  def zero?(0), do: true
  def zero?(x) when is_integer(x), do: false

  def is_function? do
    fun = &zero?/1

    is_function(fun)
  end

  @doc """
  The &1 represents the first argument passed into the function.
  &(&1 + 1) above is exactly the same as fn x -> x + 1 end.
  The syntax above is useful for short function definitions.
  """
  def capture_function_short do
    &(&1 + 1)
  end

  def capture_function do
    fn x -> x + 1 end
  end

  def default_argument(a, b, sep \\ " ") do
    a <> sep <> b
  end

  def single_default(value \\ "hello") do
    value
  end

  @doc """
  If a function with default values has multiple clauses,
  it is required to create a function head (without an actual body)
  for declaring defaults

  In this case just the function head has the defaults
  """
  def default_with_clause(a, b \\ nil, sep \\ " " )
  def default_with_clause(a, b, _sep) when is_nil(b) do
    a
  end
  def default_with_clause(a, b, sep), do: a <> sep <> b
end
