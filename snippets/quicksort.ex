defmodule Quicksort do
  # Sorting the empty list and the singleton list is trivial
  def quicksort([]), do: []
  def quicksort([x]), do: [x]

  # To sort a list,
  # we use the first element as "pivot",
  # then put all smaller elements to its left,
  # all all larger elements to its right,
  # and then sort each sides again until
  # we come to a trivial case [] or [x].
  def quicksort([x|xs]) do
    smaller = Enum.filter(xs, fn y -> y < x end)
    larger = Enum.filter(xs, fn y -> y >= x end)
    quicksort(smaller) ++ [x] ++ quicksort(larger)
  end
end