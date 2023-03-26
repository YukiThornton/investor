defmodule InvestorTest do
  use ExUnit.Case
  alias App.Investor, as: Investor
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

  describe "App.Investor.append_amount_one_by_one/2" do
    test "Appends 1 to the items with the largest target ratio diff" do

      portfolio = [
        %{:ratio => 0.7, :target_ratio => 0.7, :price => 3.0, :ticker => "t1"},
        %{:ratio => 0.3, :target_ratio => 0.7, :price => 3.0, :ticker => "t2"},
        %{:ratio => 0.7, :target_ratio => 0.5, :price => 3.0, :ticker => "t3"}
      ]

      expected = [
        %{:price => 3.0, :ticker => "t1"},
        %{:price => 3.0, :ticker => "t2"},
        %{:price => 3.0, :ticker => "t3"}
      ]

      Portfolio
      |> expect(:add_amount, fn ^portfolio, 1, 1 -> expected end)

      assert Investor.append_amount_one_by_one(portfolio, 5.0) == expected
    end

    test "Appends 1 to the items with the largest target ratio diff, skipping unaffordable one" do

      portfolio = [
        %{:ratio => 0.7, :target_ratio => 0.7, :price => 3.0, :ticker => "t1"},
        %{:ratio => 0.3, :target_ratio => 0.7, :price => 6.0, :ticker => "t2"},
        %{:ratio => 0.7, :target_ratio => 0.5, :price => 3.0, :ticker => "t3"}
      ]

      expected = [
        %{:price => 3.0, :ticker => "t1"},
        %{:price => 3.0, :ticker => "t2"},
        %{:price => 3.0, :ticker => "t3"}
      ]

      Portfolio
      |> expect(:add_amount, fn ^portfolio, 0, 1 -> expected end)

      assert Investor.append_amount_one_by_one(portfolio, 5.0) == expected
    end

    test "Repeats the process until no item is unaffordable" do

      portfolio1 = [
        %{:ratio => 0.7, :target_ratio => 0.7, :price => 4.0, :ticker => "t1"},
        %{:ratio => 0.3, :target_ratio => 0.7, :price => 6.0, :ticker => "t2"},
        %{:ratio => 0.7, :target_ratio => 0.5, :price => 3.0, :ticker => "t3"}
      ]

      portfolio2 = [
        %{:ratio => 0.7, :target_ratio => 0.7, :price => 4.0, :ticker => "t2-1"},
        %{:ratio => 0.3, :target_ratio => 0.7, :price => 6.0, :ticker => "t2-2"},
        %{:ratio => 0.7, :target_ratio => 0.5, :price => 3.0, :ticker => "t2-3"}
      ]

      portfolio3 = [
        %{:ratio => 0.7, :target_ratio => 0.7, :price => 4.0, :ticker => "t3-1"},
        %{:ratio => 0.3, :target_ratio => 0.7, :price => 6.0, :ticker => "t3-2"},
        %{:ratio => 0.7, :target_ratio => 0.5, :price => 3.0, :ticker => "t3-3"}
      ]

      Portfolio
      |> expect(:add_amount, fn ^portfolio1, 1, 1 -> portfolio2 end)
      |> expect(:add_amount, fn ^portfolio2, 0, 1 -> portfolio3 end)

      assert Investor.append_amount_one_by_one(portfolio1, 11.0) == portfolio3
    end
  end
end
