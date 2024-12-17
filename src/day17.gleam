import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import glearray.{type Array}
import utils

const input_path = "../../input/day17"

type State {
  State(a: Int, b: Int, c: Int, pc: Int, program: Array(Int))
}

pub fn main() {
  let input = utils.read_input_file_string(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> part1_result)
}

pub fn part1(input: String) -> String {
  let assert Ok(state) = parse_input(input)
  execute(state, list.new()) |> string.join(",")
}

fn parse_input(input: String) -> Result(State, Nil) {
  let assert Ok(a_re) = regexp.from_string("Register A: (-?[0-9]+)")
  let assert Ok(b_re) = regexp.from_string("Register B: (-?[0-9]+)")
  let assert Ok(c_re) = regexp.from_string("Register C: (-?[0-9]+)")
  let assert Ok(program_re) = regexp.from_string("Program: (([0-9],?)+)")

  let a_matches = regexp.scan(a_re, input)
  let b_matches = regexp.scan(b_re, input)
  let c_matches = regexp.scan(c_re, input)
  let program_matches = regexp.scan(program_re, input)

  use a_match <- result.try(list.first(a_matches))
  use b_match <- result.try(list.first(b_matches))
  use c_match <- result.try(list.first(c_matches))
  use program_match <- result.try(list.first(program_matches))

  use a_submatch <- result.try(list.first(a_match.submatches))
  use b_submatch <- result.try(list.first(b_match.submatches))
  use c_submatch <- result.try(list.first(c_match.submatches))
  use program_submatch <- result.try(list.first(program_match.submatches))

  use a_str <- result.try(option.to_result(a_submatch, Nil))
  use b_str <- result.try(option.to_result(b_submatch, Nil))
  use c_str <- result.try(option.to_result(c_submatch, Nil))
  use program_str <- result.try(option.to_result(program_submatch, Nil))

  let assert Ok(a) = int.parse(a_str)
  let assert Ok(b) = int.parse(b_str)
  let assert Ok(c) = int.parse(c_str)
  let program =
    program_str
    |> string.split(",")
    |> list.map(fn(x) {
      let assert Ok(res) = int.parse(x)
      res
    })
    |> glearray.from_list

  Ok(State(a: a, b: b, c: c, pc: 0, program: program))
}

fn combo_value(state: State, combo: Int) -> Int {
  case combo {
    0 | 1 | 2 | 3 -> combo
    4 -> state.a
    5 -> state.b
    6 -> state.c
    _ -> panic as "Erroneous combo operand"
  }
}

fn execute(state: State, acc: List(String)) -> List(String) {
  case execute_current_instruction(state) {
    Ok(#(s, None)) -> execute(s, acc)
    Ok(#(s, Some(output))) -> execute(s, list.prepend(acc, output))
    _ -> list.reverse(acc)
  }
}

fn execute_current_instruction(
  state: State,
) -> Result(#(State, Option(String)), Nil) {
  case
    glearray.get(state.program, state.pc),
    glearray.get(state.program, state.pc + 1)
  {
    Ok(0), Ok(operand) -> {
      let combo = combo_value(state, operand)
      let assert Ok(denominator) = int.power(2, int.to_float(combo))
      let a = int.to_float(state.a) /. denominator
      Ok(#(State(..state, a: float.truncate(a), pc: state.pc + 2), None))
    }
    Ok(1), Ok(operand) -> {
      let b = int.bitwise_exclusive_or(state.b, operand)
      Ok(#(State(..state, b: b, pc: state.pc + 2), None))
    }
    Ok(2), Ok(operand) -> {
      let combo = combo_value(state, operand)
      let assert Ok(b) = int.modulo(combo, 8)
      Ok(#(State(..state, b: b, pc: state.pc + 2), None))
    }
    Ok(3), Ok(operand) -> {
      case state.a {
        0 -> Ok(#(State(..state, pc: state.pc + 2), None))
        _ -> Ok(#(State(..state, pc: operand), None))
      }
    }
    Ok(4), Ok(_) -> {
      let b = int.bitwise_exclusive_or(state.b, state.c)
      Ok(#(State(..state, b: b, pc: state.pc + 2), None))
    }
    Ok(5), Ok(operand) -> {
      let combo = combo_value(state, operand)
      let assert Ok(val) = int.modulo(combo, 8)
      let s = int.to_string(val)
      Ok(#(State(..state, pc: state.pc + 2), Some(s)))
    }
    Ok(6), Ok(operand) -> {
      let combo = combo_value(state, operand)
      let assert Ok(denominator) = int.power(2, int.to_float(combo))
      let b = int.to_float(state.a) /. denominator
      Ok(#(State(..state, b: float.truncate(b), pc: state.pc + 2), None))
    }
    Ok(7), Ok(operand) -> {
      let combo = combo_value(state, operand)
      let assert Ok(denominator) = int.power(2, int.to_float(combo))
      let c = int.to_float(state.a) /. denominator
      Ok(#(State(..state, c: float.truncate(c), pc: state.pc + 2), None))
    }
    _, _ -> Error(Nil)
  }
}
