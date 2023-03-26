defmodule App.Investor do
  alias App.Portfolio, as: Portfolio

  def map_to_every_purchaseable_amount_within_budget(%{price: price} = item, budget) do
    max_amount = floor(budget / price)
    0..max_amount |> Enum.to_list() |> Enum.map(&(Map.put(item, :amount, &1)))
  end

  def append_amount_one_by_one(portfolio, budget) do
    case portfolio |> Enum.filter(fn %{price: p} -> p <= budget end) do
      [] -> portfolio
      filtered ->
        %{ticker: ticker, price: price} = filtered |> Enum.sort_by(&Portfolio.calc_target_ratio_diff/1) |> Enum.at(0)
        index = portfolio |> Enum.find_index(fn %{ticker: t} -> t == ticker end)
        append_amount_one_by_one(Portfolio.add_amount(portfolio, index, 1), budget - price)
      end
  end

  def suggest_what_to_buy(portfolio, %{max: max} = budget) do
    initial = portfolio
    |> Enum.map(&(Map.put(&1, :amount, 0)))
    |> Portfolio.append_ratio
    |> Portfolio.append_cost

    append_amount_one_by_one(initial, max)
  end
end
