defmodule App.Portfolio do

  def append_ratio(items)  do
    sum = items |> Stream.map(&calc_total_value/1) |> Enum.sum()
    items |> Enum.map(&(Map.put(&1, :ratio, calc_total_value(&1) / sum)))
  end

  def append_cost(items) do
    items |> Enum.map(&(Map.put(&1, :cost, calc_cost(&1))))
  end

  defp calc_total_value(%{price: price, holdings: holdings, amount: amount}) do
    price * (holdings + amount)
  end

  defp calc_total_value(%{price: price, holdings: holdings}) do
    price * holdings
  end

  defp calc_cost(%{price: price, amount: amount}) do
    price * amount
  end

  defp map_at(enumerable, index, f) do
    enumerable |> Enum.with_index(fn element, i -> if i == index, do: f.(element), else: element end)
  end

  def add_amount(portfolio_item, amount) do
    {_, result} = Map.get_and_update!(portfolio_item, :amount, fn current -> {current, current + amount} end)
    result
  end

  def add_amount(portfolio, index, amount) do
    portfolio
    |> map_at(index, &(add_amount(&1, amount)))
    |> append_ratio
    |> append_cost
  end

  def calc_target_ratio_diff(%{ratio: ratio, target_ratio: target_ratio}) do
    ratio - target_ratio
  end
end
