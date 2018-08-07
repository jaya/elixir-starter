defmodule TodoList.Md5HashTest do
  use ExUnit.Case

  alias TodoList.Md5Hash

  test "convert id 1" do
    assert Md5Hash.generate(1) == "C4CA4238A0B923820DCC509A6F75849B"
  end

  test "convert id 2" do
    assert Md5Hash.generate(2) == "C81E728D9D4C2F636F067F89CC14862C"
  end
end
