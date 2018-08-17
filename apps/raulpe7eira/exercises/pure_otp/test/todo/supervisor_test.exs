defmodule TODO.SupervisorTest do
  use ExUnit.Case, async: true
  doctest TODO.Supervisor
  @moduletag :supervisor

  setup do
    module = {TODO.Supervisor, name: TODO.Supervisor}
    supervisor = start_supervised! module

    %{supervisor: supervisor, module: module}
  end

  describe "TODO.Supervisor.start_link/1" do
    test "expected: a pid", context do
      assert is_pid context.supervisor
    end

    test "expected: a error message w/ ':already_started'", context do
      response = start_supervised context.module

      assert {:error, {:already_started, _pid}} = response
    end
  end

  describe "TODO.Supervisor [strategy: one_for_one]" do
    test "expected: the restarted server when it to die", context do
      [{_id, child, _type, _modules} | _tail] = Supervisor.which_children context.supervisor

      assert child == Process.whereis TODO.Server

      Process.exit child, :kill
      Process.sleep 1

      assert child != Process.whereis TODO.Server
    end
  end

end
