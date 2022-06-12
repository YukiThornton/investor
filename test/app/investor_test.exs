defmodule InvestorTest do
  use ExUnit.Case
  alias App.Investor, as: Investor
  doctest Investor

  describe "App.Investor.map_to_every_purchaseable_amount_within_budget/2" do
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
