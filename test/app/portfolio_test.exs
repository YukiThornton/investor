defmodule PortfolioTest do
  use ExUnit.Case
  alias App.Portfolio, as: Target
  doctest Target

  describe "normalize" do
    test "adds 0 amount and calculates ratio and cost" do
      input = [
        %{:price => 5.0, :holdings => 7},
        %{:price => 15.0, :holdings => 1}
      ]

      expected = [
        %{:price => 5.0, :holdings => 7, :amount => 0, :cost => 0.0, :ratio => 0.7},
        %{:price => 15.0, :holdings => 1, :amount => 0, :cost => 0.0, :ratio => 0.3}
      ]

      assert Target.normalize(input) == expected
    end

    test "when each element already has amount, recalculate ratio and cost" do
      input = [
        %{:price => 5.0, :holdings => 5, :amount => 2},
        %{:price => 15.0, :holdings => 1, :amount=> 0}
      ]

      expected = [
        %{:price => 5.0, :holdings => 5, :amount => 2, :cost => 10.0, :ratio => 0.7},
        %{:price => 15.0, :holdings => 1, :amount => 0, :cost => 0.0, :ratio => 0.3}
      ]

      assert Target.normalize(input) == expected
    end
  end

  describe "append_ratio/1" do
    test "calculates current ratio with price and holdings for each element" do
      input = [
        %{:price => 5.0, :holdings => 7},
        %{:price => 15.0, :holdings => 1}
      ]

      expected = [
        %{:price => 5.0, :holdings => 7, :ratio => 0.7},
        %{:price => 15.0, :holdings => 1, :ratio => 0.3}
      ]

      actual = Target.append_ratio(input)

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

      actual = Target.append_ratio(input)

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

      actual = Target.append_ratio(input)

      assert actual == expected
    end
  end

  describe "append_cost/1" do
    test "calculates cost with price and amount" do
      input = [
        %{price: 20.0, amount: 3},
        %{price: 12.4, amount: 2},
      ]

      expected = [
        %{price: 20.0, amount: 3, cost: 60.0},
        %{price: 12.4, amount: 2, cost: 24.8},
      ]

      assert Target.append_cost(input) == expected
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

      assert Target.append_cost(input) == expected
    end
  end

  describe "add_amount/3" do
    test "calculates" do

      input = [
        %{:price => 5.0, :holdings => 5, :ratio => 0.7, :amount => 2, :cost=> 10.0},
        %{:price => 15.0, :holdings => 1, :ratio => 0.3, :amount => 0, :cost => 0}
      ]

      expected = [
        %{:price => 5.0, :holdings => 5, :ratio => 0.75, :amount => 4, :cost=> 20.0},
        %{:price => 15.0, :holdings => 1, :ratio => 0.25, :amount => 0, :cost => 0}
      ]

      assert Target.add_amount(input, 0, 2) == expected
    end
  end

  describe "add_amounts" do
    test "add amount to each item" do
      portfolio = [
        %{:price => 5.0, :holdings => 5, :ratio => 0.7, :amount => 2, :cost=> 10.0},
        %{:price => 15.0, :holdings => 0, :ratio => 0.3, :amount => 0, :cost => 0}
      ]

      expected = [
        %{:price => 5.0, :holdings => 5, :ratio => 0.75, :amount => 4, :cost=> 20.0},
        %{:price => 15.0, :holdings => 0, :ratio => 0.25, :amount => 1, :cost => 15.0}
      ]

      assert Target.add_amounts(portfolio, [2,1]) == expected
    end
  end

  describe "calc_target_ratio_diff/1" do
    test "it returns current ratio - target ratio" do
      assert Float.round(Target.calc_target_ratio_diff( %{:ratio => 0.6, :target_ratio => 0.5}), 5) == 0.1
      assert Float.round(Target.calc_target_ratio_diff( %{:ratio => 0.3, :target_ratio => 0.5}), 5) == -0.2
    end
  end
end
