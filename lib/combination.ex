defmodule Combination do

  defp create_combinations(result, [first | []]) do
    for r <- result, f <- first, do: r ++ [f]
  end

  defp create_combinations(result, [first | tail]) do
    create_combinations(create_combinations(result, [first]), tail)
  end

  def create_combinations([first | rest]) do
    create_combinations(Enum.chunk_every(first, 1), rest)
  end

end
