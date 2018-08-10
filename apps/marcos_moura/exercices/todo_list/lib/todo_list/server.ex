defmodule TodoList.Server do

  alias TodoList.Repository

   def loop(list) do
    receive do
      {:add, todo, caller} ->
        case Repository.valid?(todo, list) do
          false ->
            send(__MODULE__, {:invalid, "task already created", caller})
            loop(list)
          true ->
            new_todo = Repository.build(todo, length(list) + 1)

            send(caller, new_todo)
            loop([new_todo | list])
        end

      {:list, caller} ->
        send(caller, list)
        loop(list)

      {:completed, id, caller} ->
        case Repository.completed?(id, list) do
          true ->
            send(__MODULE__, {:invalid, "task already completed", caller})
            loop(list)
          false ->
            list = Repository.complete(id, list)
            send(__MODULE__, {:show, id, list, caller})
            loop(list)
        end

      {:show, id, list, caller} ->
        todo = Repository.find(id, list)

        send(caller, todo)
        loop(list)

      {:invalid, message, caller} ->
        send(caller, %{invalid: message})
        loop(list)
    after
      50_000 -> :no_messages
    end
  end
end
