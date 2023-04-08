defmodule PurchasePlanTest do
  use ExUnit.Case
  alias App.PurchasePlan, as: Target
  alias App.Portfolio, as: Portfolio
  alias App.Combination, as: Combination
  doctest Target
  use Mimic

  describe "convert_into_plan" do
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
      assert Target.convert_into_plan(input) == expected
    end
  end

  describe "is_within_budget?/2" do

    test "returns true if total_cost is same or within max budget AND same or over min budget" do
      item = %{total_cost: 30.2}
      assert Target.is_within_budget?(item, %{max: 30.2, min: 30.2}) == true
      assert Target.is_within_budget?(item, %{max: 30.3, min: 30.1}) == true
    end

    test "returns false if total_cost is over max budget" do
      item = %{total_cost: 30.2}
      assert Target.is_within_budget?(item, %{max: 30.1, min: 20.0}) == false
    end

    test "returns false if total_cost is under min budget" do
      item = %{total_cost: 30.2}
      assert Target.is_within_budget?(item, %{max: 50.0, min: 30.3}) == false
    end
  end

  describe "create_bottom_up_plan/2" do
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

      assert Target.create_bottom_up_plan(portfolio, 5.0) == expected
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

      assert Target.create_bottom_up_plan(portfolio, 5.0) == expected
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

      assert Target.create_bottom_up_plan(portfolio1, 11.0) == portfolio3
    end
  end

  describe "find_smallest_diff_portfolios" do
    test "find smallest diff portfolio" do
      budget = %{max: 100.0, min: 0.0}
      p1 = [
        %{:ratio => 0.5, :target_ratio => 0.7, :price => 6.0, :cost => 54.0},
        %{:ratio => 0.5, :target_ratio => 0.3, :price => 3.0, :cost => 24.0}
      ]
      p2 = [
        %{:ratio => 0.6, :target_ratio => 0.7, :price => 6.0, :cost => 36.0},
        %{:ratio => 0.4, :target_ratio => 0.3, :price => 3.0, :cost => 12.0}
      ]
      p3 = [
        %{:ratio => 0.55, :target_ratio => 0.7, :price => 6.0, :cost => 60.0},
        %{:ratio => 0.45, :target_ratio => 0.3, :price => 3.0, :cost => 0.0}
      ]
      portfolios = [p1, p2, p3]

      assert Target.find_smallest_diff_portfolio(portfolios, budget) == p2
    end

    test "find smallest diff portfolio which is over min budget" do
      budget = %{max: 100.0, min: 50.0}
      p1 = [
        %{:ratio => 0.5, :target_ratio => 0.7, :price => 6.0, :cost => 54.0},
        %{:ratio => 0.5, :target_ratio => 0.3, :price => 3.0, :cost => 24.0}
      ]
      p2 = [
        %{:ratio => 0.6, :target_ratio => 0.7, :price => 6.0, :cost => 36.0},
        %{:ratio => 0.4, :target_ratio => 0.3, :price => 3.0, :cost => 12.0}
      ]
      p3 = [
        %{:ratio => 0.55, :target_ratio => 0.7, :price => 6.0, :cost => 60.0},
        %{:ratio => 0.45, :target_ratio => 0.3, :price => 3.0, :cost => 0.0}
      ]
      portfolios = [p1, p2, p3]

      assert Target.find_smallest_diff_portfolio(portfolios, budget) == p3
    end

    test "find smallest diff portfolio which is under max budget" do
      budget = %{max: 100.0, min: 50.0}
      p1 = [
        %{:ratio => 0.5, :target_ratio => 0.7, :price => 6.0, :cost => 54.0},
        %{:ratio => 0.5, :target_ratio => 0.3, :price => 3.0, :cost => 24.0}
      ]
      p2 = [
        %{:ratio => 0.6, :target_ratio => 0.7, :price => 6.0, :cost => 136.0},
        %{:ratio => 0.4, :target_ratio => 0.3, :price => 3.0, :cost => 12.0}
      ]
      p3 = [
        %{:ratio => 0.55, :target_ratio => 0.7, :price => 6.0, :cost => 60.0},
        %{:ratio => 0.45, :target_ratio => 0.3, :price => 3.0, :cost => 0.0}
      ]
      portfolios = [p1, p2, p3]

      assert Target.find_smallest_diff_portfolio(portfolios, budget) == p3
    end
  end

  describe "create_smallest_diff_plan" do
    test "creates random plans and returns the smallest diff one" do
      portfolio = [
        %{:ratio => 0.3, :target_ratio => 0.7, :price => 6.0, :ticker => "t2"},
        %{:ratio => 0.7, :target_ratio => 0.3, :price => 3.0, :ticker => "t3"}
      ]
      budget = %{max: 100.0, min: 10.0}
      p1 = [
        %{:ratio => 0.5, :target_ratio => 0.7, :price => 6.0, :cost => 54.0},
        %{:ratio => 0.5, :target_ratio => 0.3, :price => 3.0, :cost => 24.0}
      ]
      p2 = [
        %{:ratio => 0.6, :target_ratio => 0.7, :price => 6.0, :cost => 36.0},
        %{:ratio => 0.4, :target_ratio => 0.3, :price => 3.0, :cost => 12.0}
      ]

      Combination
      |> expect(:create_permutations, fn _, 2 -> [[9, 8], [6, 4]] end)

      Portfolio
      |> expect(:add_amounts, fn ^portfolio, [9, 8] -> p1 end)
      |> expect(:add_amounts, fn ^portfolio, [6, 4] -> p2 end)

      assert Target.create_smallest_diff_plan(portfolio, budget) == p2
    end
  end
end
