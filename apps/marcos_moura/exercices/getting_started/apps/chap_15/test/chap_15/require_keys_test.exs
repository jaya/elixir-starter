defmodule RequireKeysTest do
  use ExUnit.Case

  alias Chap15.RequiredKeys

  test "default key and required " do
    assert %RequiredKeys{make: :ok} == %RequiredKeys{make: :ok, model: nil}
  end
end
