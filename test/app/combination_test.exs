defmodule App.CombinationTest do
  use ExUnit.Case
  alias App.Combination, as: Combination
  doctest App.Combination

  describe "App.Combination.create_combinations/1" do
    test "creats combination by taking 1 element from each array" do
      input = [
        [:a1, :a2],
        [:b1],
        [:c1, :c2, :c3]
      ]

      expected = [
        [:a1, :b1, :c1], [:a1, :b1, :c2], [:a1, :b1, :c3],
        [:a2, :b1, :c1], [:a2, :b1, :c2], [:a2, :b1, :c3]
      ]

      actual = Combination.create_combinations(input)

      assert MapSet.equal?(MapSet.new(actual), MapSet.new(expected))
    end
  end

  describe "create_permutations" do
    test "creates permutations of range from 0 to max" do
      expected = [
        [0, 0], [0, 1], [0, 2], [0, 3],
        [1, 0], [1, 1], [1, 2], [1, 3],
        [2, 0], [2, 1], [2, 2], [2, 3],
        [3, 0], [3, 1], [3, 2], [3, 3],
      ]

      actual = Combination.create_permutations(3, 2)

      assert MapSet.new(actual) == MapSet.new(expected)
    end
  end
end
