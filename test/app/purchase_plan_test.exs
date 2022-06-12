defmodule PurchasePlanTest do
  use ExUnit.Case
  alias App.PurchasePlan, as: PurchasePlan
  doctest PurchasePlan

  describe "App.PurchasePlan.convert_into_plan" do
    test "creates plan with total cost and absolute ratio diff" do
      input = [
        %{ticker: "HOG", cost: 50.0, ratio: 0.2, target_ratio: 0.5},
        %{ticker: "FUG", cost: 150.0, ratio: 0.8, target_ratio: 0.7},
      ]

      expected = %{
        total_cost: 200.0,
        absolute_ratio_diff: 0.4,
        items: [
          %{ticker: "HOG", cost: 50.0, ratio: 0.2, target_ratio: 0.5},
          %{ticker: "FUG", cost: 150.0, ratio: 0.8, target_ratio: 0.7},
        ]
      }
      assert PurchasePlan.convert_into_plan(input) == expected
    end
  end

  describe "App.PurchasePlan.is_within_budget?/2" do

    test "returns true if total_cost is same or within max budget AND same or over min budget" do
      item = %{total_cost: 30.2}
      assert PurchasePlan.is_within_budget?(item, %{max: 30.2, min: 30.2}) == true
      assert PurchasePlan.is_within_budget?(item, %{max: 30.3, min: 30.1}) == true
    end

    test "returns false if total_cost is over max budget" do
      item = %{total_cost: 30.2}
      assert PurchasePlan.is_within_budget?(item, %{max: 30.1, min: 20.0}) == false
    end

    test "returns false if total_cost is under min budget" do
      item = %{total_cost: 30.2}
      assert PurchasePlan.is_within_budget?(item, %{max: 50.0, min: 30.3}) == false
    end
  end
end
