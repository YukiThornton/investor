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

end
