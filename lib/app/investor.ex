defmodule App.Investor do
  alias App.Portfolio, as: Portfolio
  alias App.PurchasePlan, as: PurchasePlan

  def map_to_every_purchaseable_amount_within_budget(%{price: price} = item, budget) do
    max_amount = floor(budget / price)
    0..max_amount |> Enum.to_list() |> Enum.map(&(Map.put(item, :amount, &1)))
  end

  def make_plans(portfolio, %{max: max} = budget) do
    normalized = portfolio |> Portfolio.normalize
    %{
      bottom_up: PurchasePlan.create_bottom_up_plan(normalized, max),
      smallest_diff: PurchasePlan.create_smallest_diff_plan(normalized, budget)
    }
  end
end
