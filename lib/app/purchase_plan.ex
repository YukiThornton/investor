defmodule App.PurchasePlan do
  alias App.Portfolio, as: Portfolio
  alias App.Combination, as: Combination

  def convert_into_plan(items) do
    %{
      absolute_ratio_diff: items |> Stream.map(&(Float.round(abs(&1.target_ratio - &1.ratio), 4))) |> Enum.sum(),
      total_cost: items |> Stream.map(&(&1.cost)) |> Enum.sum(),
      items: items
    }
  end

  def is_within_budget?(%{total_cost: total_cost}, %{min: min, max: max}) do
    total_cost <= max && total_cost >= min
  end

  def create_bottom_up_plan(portfolio, max_budget) do
    case portfolio |> Enum.filter(fn %{price: p} -> p <= max_budget end) do
      [] -> portfolio
      filtered ->
        %{ticker: ticker, price: price} = filtered |> Enum.sort_by(&Portfolio.calc_target_ratio_diff/1) |> Enum.at(0)
        index = portfolio |> Enum.find_index(fn %{ticker: t} -> t == ticker end)
        create_bottom_up_plan(Portfolio.add_amount(portfolio, index, 1), max_budget - price)
      end
  end

  defp ratio_diff_abs(%{ratio: ratio, target_ratio: target}) do
    abs(target - ratio)
  end

  defp ratio_diff_abs_total(portfolio) do
    portfolio
    |> Stream.map(&ratio_diff_abs(&1))
    |> Enum.sum
  end

  defp total_cost(portfolio) do
    portfolio
    |> Stream.map(fn p -> p.cost end)
    |> Enum.sum()
  end

  def find_smallest_diff_portfolio(portfolios, %{max: max, min: min}) do
    portfolios
    |> Enum.filter(fn p -> total_cost(p) >= min end)
    |> Enum.filter(fn p -> total_cost(p) <= max end)
    |> Enum.min_by(&ratio_diff_abs_total(&1))
  end

  def create_smallest_diff_plan(portfolio, budget) do
    max_count = 5
    Combination.create_permutations(max_count, Enum.count(portfolio))
    |> Enum.map(&Portfolio.add_amounts(portfolio, &1))
    |> find_smallest_diff_portfolio(budget)
  end
end
