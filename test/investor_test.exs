defmodule InvestorTest do
  use ExUnit.Case
  doctest Investor

  test "suggests what to buy" do
    budget = %{max: 50.0, min: 40.0}
    portfolio = [
      %{:ticker => "HOG", :price => 10.2, :holdings => 2, :target_ratio => 0.3},
      %{:ticker => "FUG", :price => 15.1, :holdings => 1, :target_ratio => 0.7}
    ]

    expected = [
      %{:ticker => "HOG", :amount => 0},
      %{:ticker => "FUG", :amount => 3},
    ]

    actual = Investor.suggest_what_to_buy(budget, portfolio)
    IO.inspect(actual)
    # assert actual == expected
  end

  describe "Investor.map_to_every_purchaseable_amount_within_budget/2" do
    test "calculates every possible amount under budget and map to a list of item with the amount" do
      item = %{price: 12.0}
      budget = 40

      expected = [%{price: 12.0, amount: 0}, %{price: 12.0, amount: 1}, %{price: 12.0, amount: 2}, %{price: 12.0, amount: 3}]

      actual = Investor.map_to_every_purchaseable_amount_within_budget(item, budget)

      assert actual == expected
    end

    test "returns a map with 0 amount when price is over the budget" do
      item = %{price: 42.0}
      budget = 40

      expected = [%{price: 42.0, amount: 0}]

      actual = Investor.map_to_every_purchaseable_amount_within_budget(item, budget)

      assert actual == expected
    end
  end
end
