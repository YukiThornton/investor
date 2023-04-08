defmodule App.Combination do

  defp create_combinations(result, [first | []]) do
    for r <- result, f <- first, do: r ++ [f]
  end

  defp create_combinations(result, [first | tail]) do
    create_combinations(create_combinations(result, [first]), tail)
  end

  def create_combinations([first | rest]) do
    create_combinations(Enum.chunk_every(first, 1), rest)
  end

  def permute([], _size) do
    [[]]
  end

  def permute(_list, 0) do
    [[]]
  end

  def permute(list, size) do
    for head <- list, tail <- permute(list, size - 1), do: [head | tail]
  end

  def create_permutations(max, size) do
    permute(Enum.to_list(0..max), size)
  end
end
