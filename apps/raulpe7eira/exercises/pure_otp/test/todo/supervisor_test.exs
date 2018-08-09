defmodule TODO.SupervisorTest do
  use ExUnit.Case, async: true
  doctest TODO.Supervisor

  import ExUnit.CaptureIO

  describe "TODO.Supervisor.start/0" do
    # test "expected: a success message" do
    #   assert capture_io(fn -> TODO.Supervisor.start() end) == "~> Supervisor is started.\n"
    # end

    # test "expected: a error message" do
    #   assert capture_io(fn ->
    #     TODO.Supervisor.start()
    #     TODO.Supervisor.start()
    #   end) == "~> Supervisor is started.\n~> Supervisor is already starting.\n"
    # end

    # test "expected: a restarted message" do
    #   assert capture_io(fn ->
    #     TODO.Supervisor.start()
    #     TODO.shutdown()
    #   end) == "~> Supervisor: ops... TODO?!\n~> Supervisor: restarted TODO.\n"
    # end
  end
end
