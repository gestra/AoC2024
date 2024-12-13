import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import utils

const input_path = "../../input/day13"

pub type Machine {
  Machine(a: #(Int, Int), b: #(Int, Int), prize: #(Int, Int))
}

fn get_matches(re: regexp.Regexp, str: String) -> #(Int, Int) {
  case regexp.scan(re, str) {
    [match] -> {
      case match.submatches {
        [option.Some(x_match), option.Some(y_match)] -> {
          let assert Ok(x) = int.parse(x_match)
          let assert Ok(y) = int.parse(y_match)
          #(x, y)
        }
        _ -> panic as "Regexp matching fail"
      }
    }
    _ -> panic as "Regexp matching fail"
  }
}

fn parse_machine(input: String) -> Machine {
  let assert Ok(re) = regexp.from_string(".*X.([0-9]+), Y.([0-9]+)")
  input
  |> string.split("\n")
  |> fn(l) {
    case l {
      [a_str, b_str, prize_str] ->
        Machine(
          a: get_matches(re, a_str),
          b: get_matches(re, b_str),
          prize: get_matches(re, prize_str),
        )
      _ -> panic as "Wrong number of lines"
    }
  }
}

pub fn parse_machines(input: String) -> List(Machine) {
  input
  |> string.split("\n\n")
  |> list.map(parse_machine)
}

fn wins_loop(
  machine: Machine,
  a: Int,
  b: Int,
  acc: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case a > 100 {
    True -> acc
    False -> {
      case b > 100 {
        True -> wins_loop(machine, a + 1, 0, acc)
        False -> {
          case
            a * machine.a.0 + b * machine.b.0 == machine.prize.0
            && a * machine.a.1 + b * machine.b.1 == machine.prize.1
          {
            True -> wins_loop(machine, a + 1, 0, list.prepend(acc, #(a, b)))
            False -> wins_loop(machine, a, b + 1, acc)
          }
        }
      }
    }
  }
}

fn wins(machine: Machine) -> List(#(Int, Int)) {
  wins_loop(machine, 0, 1, list.new())
}

fn minimum_tokens(machine: Machine, wins: List(#(Int, Int)), acc: Int) -> Int {
  case wins {
    [] -> acc
    [w, ..rest] ->
      case acc == 0 || w.0 * 3 + w.1 < acc {
        True -> minimum_tokens(machine, rest, w.0 * 3 + w.1)
        False -> minimum_tokens(machine, rest, acc)
      }
  }
}

fn convert_to_part2(machine: Machine) -> Machine {
  Machine(
    ..machine,
    prize: #(
      machine.prize.0 + 10_000_000_000_000,
      machine.prize.1 + 10_000_000_000_000,
    ),
  )
}

fn solve(machine: Machine) -> Int {
  let b =
    {
      int.to_float(machine.prize.1)
      -. {
        { int.to_float(machine.a.1) *. int.to_float(machine.prize.0) }
        /. int.to_float(machine.a.0)
      }
    }
    /. {
      int.to_float(machine.b.1)
      -. {
        { int.to_float(machine.b.0) *. int.to_float(machine.a.1) }
        /. int.to_float(machine.a.0)
      }
    }
  let a =
    { int.to_float(machine.prize.0) -. { int.to_float(machine.b.0) *. b } }
    /. int.to_float(machine.a.0)

  let ai = float.round(a)
  let bi = float.round(b)
  case
    ai * machine.a.0 + bi * machine.b.0 == machine.prize.0
    && ai * machine.a.1 + bi * machine.b.1 == machine.prize.1
  {
    True -> {
      3 * ai + bi
    }
    False -> 0
  }
}

pub fn main() {
  let input =
    utils.read_input_file_string(input_path) |> string.trim |> parse_machines

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

pub fn part1(input: List(Machine)) -> Int {
  input
  |> list.map(fn(x) { #(x, wins(x)) })
  |> list.filter(fn(x) { x.1 != [] })
  |> list.map(fn(x) { minimum_tokens(x.0, x.1, 0) })
  |> int.sum
}

pub fn part2(input: List(Machine)) -> Int {
  input
  |> list.map(convert_to_part2)
  |> list.map(solve)
  |> int.sum
}
