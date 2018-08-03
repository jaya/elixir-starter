defmodule Cap7KeywordListAndMaps do
  @moduledoc """
  Documentation for Cap7KeywordListAndMaps.
  """

  @doc """
    iex> Cap7KeywordListAndMaps.list_default_notation
    [a: "a", b: "b"]
  """
  def list_default_notation do
    [{:a, "a"}, {:b, "b"}]
  end

  def list_special_notation do
    [a: "a", b: "b"]
  end

  def append(value, list) do
    list ++ value
  end

  def prepend(value, list) do
    value ++ list
  end

  @doc """
  On keyword lists the on added to the front are the one fetched on lookup
  iex> Cap7KeywordListAndMaps.get(:one, two: 2, one: 1, one: 0)
  1
  """
  def get(key, list) do
    list[key]
  end

  @doc """
  iex> Cap7KeywordListAndMaps.match(a: 1)
  [a: 1]

  iex> Cap7KeywordListAndMaps.match(b: 2)
  ** (MatchError) no match of right hand side value: [b: 2]
  """
  def match(value) do
    [a: 1] = value
  end

  @doc """
  * Maps allow any value as a key
  * Map's keys do not follow any order

  iex> Cap7KeywordListAndMaps.simple_map()
  %{:a => 1, 2 => :b}
  """
  def simple_map do
    %{:a => 1, 2 => :b}
  end

  @doc """
  iex> Cap7KeywordListAndMaps.map_match(%{:a => 1, 2 => :b})
  %{2 => :b, :a => 1}

  iex> Cap7KeywordListAndMaps.map_match(%{:c => 1, 2 => :b})
  ** (MatchError) no match of right hand side value: %{2 => :b, :c => 1}
  """
  def map_match(map) do
    %{:a => a} = map
  end

  @doc """
  iex> Cap7KeywordListAndMaps.map_to_list(%{1 => :one, :two => 2})
  [{1, :one}, {:two, 2}]
  """
  def map_to_list(map) do
    Map.to_list(map)
  end
end
