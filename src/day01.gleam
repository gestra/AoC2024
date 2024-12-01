import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

const input_path = "../../input/day01"

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn tuple_from_line(input: String) -> #(Int, Int) {
  let assert Ok(strings) = string.split_once(input, "   ")
  let assert Ok(left) = int.parse(strings.0)
  let assert Ok(right) = int.parse(strings.1)

  #(left, right)
}

fn split_lists(
  tuples: List(#(Int, Int)),
  acc: #(List(Int), List(Int)),
) -> #(List(Int), List(Int)) {
  case tuples {
    [first, ..rest] ->
      split_lists(rest, #([first.0, ..acc.0], [first.1, ..acc.1]))
    [] -> acc
  }
}

fn distances(lists: #(List(Int), List(Int)), acc: List(Int)) -> List(Int) {
  case lists.0, lists.1 {
    [left_first, ..left_rest], [right_first, ..right_rest] ->
      distances(#(left_rest, right_rest), [
        int.absolute_value(left_first - right_first),
        ..acc
      ])
    [], [] -> acc
    _, _ -> panic as "List were not equally long"
  }
}

fn similarity(lists: #(List(Int), List(Int)), acc: Int) -> Int {
  case lists.0 {
    [first, ..rest] ->
      similarity(
        #(rest, lists.1),
        acc + first * list.count(lists.1, fn(x) { x == first }),
      )
    [] -> acc
  }
}

pub fn part1(input: List(String)) -> Int {
  input
  |> list.map(tuple_from_line)
  |> split_lists(#(list.new(), list.new()))
  |> fn(x) { #(list.sort(x.0, int.compare), list.sort(x.1, int.compare)) }
  |> distances(list.new())
  |> list.fold(0, int.add)
}

pub fn part2(input: List(String)) -> Int {
  input
  |> list.map(tuple_from_line)
  |> split_lists(#(list.new(), list.new()))
  |> similarity(0)
}
