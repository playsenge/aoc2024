defmodule Parser do
  def parse([]), do: 0

  def parse(x) do
    instruction = "mul("
    char_count = instruction |> String.length()

    nums = x |> Enum.drop(char_count) |> Enum.join("") |> String.split(",")

    if length(nums) != 2 or x |> Enum.take(char_count) != instruction |> String.graphemes() do
      0
    else
      nums
      |> Enum.map(fn x ->
        case Integer.parse(x) do
          {int, _} -> int
          :error -> 0
        end
      end)
      |> Enum.product()
    end
  end
end

data = File.read!("data/day3.txt") |> String.trim() |> String.graphemes()

result =
  Enum.reduce(
    data,
    %{
      :sum_part1 => 0,
      :sum_part2 => 0,
      :chars => [],
      :found => false,
      :found_toggle => false,
      :part2_multiplier => 1
    },
    fn x, acc ->
      return_value =
        cond do
          # Start of \do\ or \dont\ command
          x == "d" ->
            %{
              acc
              | :chars => [x],
                :found_toggle => true
            }

          # Constructed \do\ or \dont\ string, parsing
          acc.found_toggle and x == "(" ->
            abc =
              case acc.chars |> Enum.join("") do
                "do" ->
                  %{
                    acc
                    | :chars => [],
                      :found_toggle => false,
                      :part2_multiplier => 1
                  }

                "don't" ->
                  %{
                    acc
                    | :chars => [],
                      :found_toggle => false,
                      :part2_multiplier => 0
                  }

                _ ->
                  %{
                    acc
                    | :chars => [],
                      :found_toggle => false
                  }
              end

            abc

          # Ending \mul(\
          x == ")" ->
            %{
              acc
              | :sum_part1 => acc.sum_part1 + Parser.parse(acc.chars),
                :sum_part2 => acc.sum_part2 + Parser.parse(acc.chars) * acc.part2_multiplier,
                :chars => [],
                :found => false,
                :found_toggle => false
            }

          x == "m" ->
            %{
              acc
              | :chars => [x],
                :found => true,
                :found_toggle => false
            }

          # Building chars for \do()\, \dont()\ and \mul(...)\
          (acc.found or acc.found_toggle) and String.contains?("0123456789,mul(don't(do", x) ->
            %{
              acc
              | :chars => acc.chars ++ [x]
            }

          # Otherwise, reset
          true ->
            %{
              acc
              | :chars => [],
                :found => false,
                :found_toggle => false
            }
        end

      return_value
    end
  )

IO.puts(result.sum_part1)
IO.puts(result.sum_part2)
