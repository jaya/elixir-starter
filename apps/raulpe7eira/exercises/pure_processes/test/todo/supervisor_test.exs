defmodule TODO.SupervisorTest do
  use ExUnit.Case, async: false
  doctest TODO.Supervisor
  @moduletag :supervisor

  import ExUnit.CaptureLog

  describe "TODO.Supervisor.start/0" do
    test "expected: a success message" do
      assert capture_log(fn ->
        TODO.Supervisor.start()
      end) =~ ~r/: is started/
    end

    test "expected: a error message" do
      assert capture_log(fn ->
        TODO.Supervisor.start()
        TODO.Supervisor.start()
      end) =~ ~r/: is already starting/
    end

    test "expected: a restarted message" do
      assert capture_log(fn ->
        TODO.Supervisor.start()
        TODO.shutdown()
      end) =~ ~r/ restarted/
    end
  end

  # It's not working perfectly... /\(:/)/\
end
