import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

const input_path = "../../input/day11"

type Stone {
  Stone(number: Int, mul: Int)
}

pub fn main() {
  let input = utils.read_input_file_string(input_path) |> string.trim

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_input_loop(input: List(String), acc: List(Int)) -> List(Int) {
  case input {
    [first, ..rest] -> {
      let assert Ok(n) = int.parse(first)
      parse_input_loop(rest, list.prepend(acc, n))
    }
    [] -> acc
  }
}

fn parse_input(input: String) -> List(Stone) {
  input
  |> string.split(" ")
  |> parse_input_loop(list.new())
  |> list.reverse
  |> list.map(fn(x) { Stone(number: x, mul: 1) })
}

fn blink(stone: Stone) -> List(Stone) {
  case stone.number {
    0 -> [Stone(number: 1, mul: stone.mul)]
    n -> {
      let str = n |> int.to_string
      let length = str |> string.length
      case length % 2 == 0 {
        True -> {
          let half = length / 2
          let assert Ok(first) = str |> string.drop_end(half) |> int.parse
          let assert Ok(second) = str |> string.drop_start(half) |> int.parse
          [
            Stone(number: first, mul: stone.mul),
            Stone(number: second, mul: stone.mul),
          ]
        }
        False -> [Stone(number: n * 2024, mul: stone.mul)]
      }
    }
  }
}

fn blink_n_times(stones: List(Stone), times_to_do: Int) -> List(Stone) {
  case times_to_do {
    0 -> stones
    _ -> {
      let new_stones =
        stones
        |> list.map(blink)
        |> list.flatten
        |> list.sort(fn(a, b) { int.compare(a.number, b.number) })
        |> list.chunk(fn(x) { x.number })
        |> list.map(fn(chunk) {
          list.fold(chunk, Stone(0, 0), fn(acc, s) {
            Stone(number: s.number, mul: acc.mul + s.mul)
          })
        })
      blink_n_times(new_stones, times_to_do - 1)
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> blink_n_times(25)
  |> list.fold(0, fn(acc, s) { acc + s.mul })
}

pub fn part2(input: String) -> Int {
  input
  |> parse_input
  |> blink_n_times(75)
  |> list.fold(0, fn(acc, s) { acc + s.mul })
}
