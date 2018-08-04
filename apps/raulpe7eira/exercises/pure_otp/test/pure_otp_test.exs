defmodule PureOtpTest do
  use ExUnit.Case
  doctest PureOtp

  test "greets the world" do
    assert PureOtp.hello() == :world
  end
end
