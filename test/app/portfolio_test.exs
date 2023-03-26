defmodule PortfolioTest do
  use ExUnit.Case
  alias App.Portfolio, as: Portfolio
  doctest Portfolio

  describe "App.Portfolio.append_ratio/1" do
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

  describe "App.Portfolio.append_cost/1" do
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

  describe "App.Portfolio.add_amount/3" do
    test "calculates" do

      input = [
        %{:price => 5.0, :holdings => 5, :ratio => 0.7, :amount => 2, :cost=> 10.0},
        %{:price => 15.0, :holdings => 1, :ratio => 0.3, :amount => 0, :cost => 0}
      ]

      expected = [
        %{:price => 5.0, :holdings => 5, :ratio => 0.75, :amount => 4, :cost=> 20.0},
        %{:price => 15.0, :holdings => 1, :ratio => 0.25, :amount => 0, :cost => 0}
      ]

      assert Portfolio.add_amount(input, 0, 2) == expected
    end
  end

  describe "App.Portfolio.calc_target_ratio_diff/1" do
    test "it returns current ratio - target ratio" do
      assert Float.round(Portfolio.calc_target_ratio_diff( %{:ratio => 0.6, :target_ratio => 0.5}), 5) == 0.1
      assert Float.round(Portfolio.calc_target_ratio_diff( %{:ratio => 0.3, :target_ratio => 0.5}), 5) == -0.2
    end
  end
end
