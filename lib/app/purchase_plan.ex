defmodule App.PurchasePlan do

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
end
