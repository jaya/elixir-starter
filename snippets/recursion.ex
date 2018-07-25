defmodule Recursion do
  def len([]) do
    0
  end

  def len([h | t]) do
    """
    len([1,2,3]) == 3
    """

    1 + len(t)
  end

  def sum([]) do
    0
  end

  def sum([h | t]) when is_integer(h) do
    h + sum(t)
  end

  def map(f, []) do
    []
  end

  def map(f, [x | xs]) do
    [f.(x) | map(f, xs)]
  end

  def squares(xs) do
    map &square/1, xs
  end

  def square(x) do
    x * x
  end
end
