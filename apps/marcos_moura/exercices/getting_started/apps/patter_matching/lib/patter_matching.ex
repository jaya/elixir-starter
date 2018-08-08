defmodule PatterMatching do
  def ok(p1) do
    {:ok, _result} = p1
  end

  def head(list) do
    [head | _tail] = list
    head
  end

  def tail(list) do
    [_head | tail] = list
    tail
  end

  def prepend(item, list), do: [item | list]

  def rebind(value) do
    x = 1
    ^x = value
  end

  def rebind_tuple(value) do
    x = 1
    {_, ^x} = {2, value}
  end

  def ignore(tuple) do
    {x, y, _} = tuple
    {x, y}
  end
end
