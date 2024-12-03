import gleam/int
import gleam/io
import gleam/option
import gleam/regexp
import gleam/string
import utils

const input_path = "../../input/day03"

pub fn main() {
  let input = utils.read_input_file_string(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn part1_loop(matches: List(regexp.Match), acc: Int) -> Int {
  case matches {
    [] -> acc
    [first, ..rest] -> {
      case first.submatches {
        [option.Some(x_str), option.Some(y_str)] -> {
          let assert Ok(x) = int.parse(x_str)
          let assert Ok(y) = int.parse(y_str)
          part1_loop(rest, acc + x * y)
        }
        _ -> panic as "Error with matching"
      }
    }
  }
}

fn part2_loop(input: String, re: regexp.Regexp, enabled: Bool, acc: Int) -> Int {
  case input {
    "" -> acc
    "don't()" <> rest -> part2_loop(rest, re, False, acc)
    "do()" <> rest -> part2_loop(rest, re, True, acc)
    "mul(" <> rest if enabled -> {
      let matches = regexp.scan(re, input)
      case matches {
        [match] -> {
          case match.submatches {
            [option.Some(x_str), option.Some(y_str)] -> {
              let assert Ok(x) = int.parse(x_str)
              let assert Ok(y) = int.parse(y_str)
              part2_loop(rest, re, enabled, acc + x * y)
            }
            _ -> panic as "Error with matching"
          }
        }
        _ -> part2_loop(rest, re, enabled, acc)
      }
    }
    _ -> part2_loop(string.drop_start(input, 1), re, enabled, acc)
  }
}

pub fn part1(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\(([0-9]+),([0-9]+)\\)")

  part1_loop(regexp.scan(re, input), 0)
}

pub fn part2(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("^mul\\(([0-9]+),([0-9]+)\\)")
  part2_loop(input, re, True, 0)
}
