defmodule InvestorTest do
  use ExUnit.Case
  alias App.Investor, as: Investor
  alias App.PurchasePlan, as: PurchasePlan
  alias App.Portfolio, as: Portfolio
  doctest Investor
  use Mimic

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

  describe "App.Investor.make_plans/2" do
    test "Creates muliple plans" do
      budget = %{max: 100, min: 50}
      expected = %{
        bottom_up: :bottom_up,
        smallest_diff: :smallest_diff
      }

      Portfolio
      |> expect(:normalize, fn :portfolio -> :normalized end)

      PurchasePlan
      |> expect(:create_bottom_up_plan, fn :normalized, 100 -> :bottom_up end)
      |> expect(:create_smallest_diff_plan, fn :normalized, ^budget -> :smallest_diff end)

      assert Investor.make_plans(:portfolio, budget) == expected
    end
  end
end
