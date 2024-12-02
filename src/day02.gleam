import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils

const input_path = "../../input/day02"

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn is_safe_loop(levels: List(Int), increasing: Bool) -> Bool {
  case levels {
    [] -> True
    [_] -> True
    [first, second, ..rest] -> {
      let diff = int.absolute_value(first - second)
      case increasing {
        True ->
          case first < second && diff <= 3 && diff >= 1 {
            True -> is_safe_loop([second, ..rest], increasing)
            False -> False
          }
        False ->
          case first > second && diff <= 3 && diff >= 1 {
            True -> is_safe_loop([second, ..rest], increasing)
            False -> False
          }
      }
    }
  }
}

fn is_safe(levels: List(Int)) -> Bool {
  case levels {
    [first, second, ..rest] -> {
      let diff = int.absolute_value(first - second)

      case first < second, diff <= 3 && diff >= 1 {
        _, False -> False
        True, True -> is_safe_loop([second, ..rest], True)
        False, True -> is_safe_loop([second, ..rest], False)
      }
    }
    [_] -> True
    [] -> True
  }
}

fn parse_levels(line: String) -> List(Int) {
  let levels =
    line
    |> string.split(" ")
    |> list.map(int.parse)

  case list.any(levels, fn(x) { x == Error(Nil) }) {
    True -> panic as "Parsing levels failed"
    False -> list.map(levels, fn(x) { result.unwrap(x, 0) })
  }
}

fn is_safe_tolerant_loop(levels: List(Int), index: Int) -> Bool {
  case index >= list.length(levels) {
    True -> False
    False -> {
      case is_safe(remove_level(levels, index)) {
        True -> True
        False -> is_safe_tolerant_loop(levels, index + 1)
      }
    }
  }
}

fn remove_level(levels: List(Int), index: Int) -> List(Int) {
  levels
  |> list.split(index)
  |> fn(x) { list.append(x.0, list.drop(x.1, 1)) }
}

fn is_safe_tolerant(levels: List(Int)) -> Bool {
  let normally_safe = is_safe(levels)

  case normally_safe {
    True -> True
    False -> {
      is_safe_tolerant_loop(levels, 0)
    }
  }
}

pub fn part1(input: List(String)) -> Int {
  input
  |> list.map(parse_levels)
  |> list.map(is_safe)
  |> list.count(fn(x) { x == True })
}

pub fn part2(input: List(String)) -> Int {
  input
  |> list.map(parse_levels)
  |> list.map(is_safe_tolerant)
  |> list.count(fn(x) { x == True })
}
