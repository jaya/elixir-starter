defmodule DefiningStructsTest do
  use ExUnit.Case

  alias Chap15.DefiningStructs

  test "default values of struct" do
    assert %DefiningStructs{} == %DefiningStructs{name: "John"}
  end


  test "custom values to struc" do
    assert %DefiningStructs{name: "Marco"} == %DefiningStructs{name: "Marco"}
  end

  test "access fields" do
    john = %DefiningStructs{}
    assert john.name == "John"
  end

  test "using the update syntax (|)" do
    john = %DefiningStructs{}
    jane = %{john | name: "Jane"}
    assert jane.name == "Jane"
  end
end
