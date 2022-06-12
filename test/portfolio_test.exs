defmodule PortfolioTest do
  use ExUnit.Case
  doctest Portfolio

  describe "Portfolio.append_ratio/1" do
    test "calculates current ratio with price and holdings for each element" do
      input = [
        %{:price => 5.0, :holdings => 7},
        %{:price => 15.0, :holdings => 1}
      ]

      expected = [
        %{:price => 5.0, :holdings => 7, :ratio => 0.7},
        %{:price => 15.0, :holdings => 1, :ratio => 0.3}
      ]

      actual = Portfolio.append_ratio(input)

      assert actual == expected
    end

    test "calculates ratio with price, holdings and amount for each element" do
      input = [
        %{price: 5.0, holdings: 5, amount: 2},
        %{price: 15.0, holdings: 1, amount: 0}
      ]

      expected = [
        %{price: 5.0, holdings: 5, amount: 2, ratio: 0.7},
        %{price: 15.0, holdings: 1, amount: 0, ratio: 0.3}
      ]

      actual = Portfolio.append_ratio(input)

      assert actual == expected
    end

    test "when each element already has ratio, updates ratio" do
      input = [
        %{price: 5.0, holdings: 5, amount: 2, ratio: 0.5},
        %{price: 15.0, holdings: 1, amount: 0, ratio: 0.5}
      ]

      expected = [
        %{price: 5.0, holdings: 5, amount: 2, ratio: 0.7},
        %{price: 15.0, holdings: 1, amount: 0, ratio: 0.3}
      ]

      actual = Portfolio.append_ratio(input)

      assert actual == expected
    end
  end

  describe "Portfolio.append_cost/1" do
    test "calculates cost with price and amount" do
      input = [
        %{price: 20.0, amount: 3},
        %{price: 12.4, amount: 2},
      ]

      expected = [
        %{price: 20.0, amount: 3, cost: 60.0},
        %{price: 12.4, amount: 2, cost: 24.8},
      ]

      assert Portfolio.append_cost(input) == expected
    end

    test "update cost if the given item already has cost" do
      input = [
        %{price: 20.0, amount: 3, cost: 90},
        %{price: 12.4, amount: 2},
      ]

      expected = [
        %{price: 20.0, amount: 3, cost: 60.0},
        %{price: 12.4, amount: 2, cost: 24.8},
      ]

      assert Portfolio.append_cost(input) == expected
    end
  end
end
