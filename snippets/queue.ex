defmodule Queue do
  defstruct [:front, :back, :count]

  def new() do
    %Queue{front: [], back: [], count: 0}
  end

  def enqueue(queue = %Queue{front: front, back: back, count: count}, new_elem) do
    # We always add items to the back list
    # the dequeue function will reverse the back list
    # and put into the front list when needed
    %Queue{queue | back: [new_elem | back], count: count + 1}
  end

  def dequeue(queue) do
    case queue do
      %{count: 0} ->
        # If the queue is empty there is nothing to return
        {:empty, queue}

      %{front: [], back: back} ->
        # If the front is empty, we swap it with the reversed back
        # and call dequee again -- it will fall back into the right case!
        dequeue(%Queue{queue | front: Enum.reverse(back), back: []})

      %{front: [h | front], count: count} ->
        # If the front is not empty, take the first element as the
        # result and decrease the counter.
        {{:value, h}, %Queue{queue | front: front, count: count - 1}}
    end
  end

  # Pattern matching is enough here.
  def size(%Queue{count: count}) do
    count
  end

  # We can convert the queue to a list by
  # appending the reversed back to the front.
  def to_list(%Queue{front: front, back: back}) do
    front ++ Enum.reverse(back)
  end
end
