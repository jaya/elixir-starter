defmodule Cap8ModulesAndFunctionsTest do
  use ExUnit.Case
  doctest Cap8ModulesAndFunctions

  test "is zero?" do
    assert Cap8ModulesAndFunctions.zero?(0) == true
  end

  test "one is not zero" do
    assert Cap8ModulesAndFunctions.zero?(1) == false
  end

  test "raise error when is not a integer" do
    assert_raise FunctionClauseError, fn -> Cap8ModulesAndFunctions.zero?("a") end
  end

  test "is function" do
    assert Cap8ModulesAndFunctions.is_function?() == true
  end

  test "capture operator '&' function short syntax" do
    assert Cap8ModulesAndFunctions.capture_function_short().(1) == 2
  end

  test "capture operator '&' function" do
    assert Cap8ModulesAndFunctions.capture_function_short().(1) == 2
  end

  test "default arguments" do
    assert Cap8ModulesAndFunctions.default_argument("hello", "world") == "hello world"
  end

  test "replacing default arguments" do
    assert Cap8ModulesAndFunctions.default_argument("hello", "world", "_") == "hello_world"
  end

  test "single default value" do
    assert Cap8ModulesAndFunctions.single_default() == "hello"
    assert Cap8ModulesAndFunctions.single_default(123) == 123
    assert Cap8ModulesAndFunctions.single_default() == "hello"
  end

  test "default value with multiple clauses" do
    assert Cap8ModulesAndFunctions.default_with_clause("Hello", "world") == "Hello world"
    assert Cap8ModulesAndFunctions.default_with_clause("Hello", "world", "_") == "Hello_world"
    assert Cap8ModulesAndFunctions.default_with_clause("Hello") == "Hello"
  end
end
