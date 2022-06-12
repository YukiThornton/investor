defmodule Investor do

  def map_to_every_purchaseable_amount_within_budget(%{price: price} = item, budget) do
    max_amount = floor(budget / price)
    0..max_amount |> Enum.to_list() |> Enum.map(&(Map.put(item, :amount, &1)))
  end

  def suggest_what_to_buy(%{max: max} = budget, portfolio) do
    portfolio
    |> Enum.map(&(map_to_every_purchaseable_amount_within_budget(&1, max)))
    |> Combination.create_combinations()
    |> Enum.map(&Portfolio.append_ratio/1)
    |> Enum.map(&Portfolio.append_cost/1)
    |> Enum.map(&PurchasePlan.convert_into_plan/1)
    |> Enum.filter(&(PurchasePlan.is_within_budget?(&1, budget)))
    |> Enum.sort_by(&(&1.absolute_ratio_diff))
  end
end
