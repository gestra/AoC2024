import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

const input_path = "../../input/day07"

type Equation {
  Equation(result: Int, numbers: List(Int))
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_equation(line: String) -> Equation {
  let assert Ok(parts) = string.split_once(line, ": ")
  let assert Ok(result) = int.parse(parts.0)
  let numbers =
    parts.1
    |> string.split(" ")
    |> list.map(fn(x) {
      let assert Ok(y) = int.parse(x)
      y
    })

  Equation(result, numbers)
}

fn equation_can_be_true_part1(eq: Equation) -> Bool {
  case eq.numbers {
    [] -> panic as "Empty numbers"
    [only] -> only == eq.result
    [first, second, ..rest] -> {
      let res_add = first + second
      let res_mul = first * second

      equation_can_be_true_part1(Equation(..eq, numbers: [res_add, ..rest]))
      || equation_can_be_true_part1(Equation(..eq, numbers: [res_mul, ..rest]))
    }
  }
}

fn equation_can_be_true_part2(eq: Equation) -> Bool {
  case eq.numbers {
    [] -> panic as "Empty numbers"
    [only] -> only == eq.result
    [first, second, ..rest] -> {
      let res_add = first + second
      let res_mul = first * second
      let assert Ok(res_concat) =
        [int.to_string(first), int.to_string(second)]
        |> string.concat
        |> int.parse

      equation_can_be_true_part2(Equation(..eq, numbers: [res_add, ..rest]))
      || equation_can_be_true_part2(Equation(..eq, numbers: [res_mul, ..rest]))
      || equation_can_be_true_part2(
        Equation(..eq, numbers: [res_concat, ..rest]),
      )
    }
  }
}

pub fn part1(input: List(String)) -> Int {
  input
  |> list.map(parse_equation)
  |> list.filter(fn(x) { equation_can_be_true_part1(x) == True })
  |> list.map(fn(x) { x.result })
  |> int.sum
}

pub fn part2(input: List(String)) -> Int {
  input
  |> list.map(parse_equation)
  |> list.filter(fn(x) { equation_can_be_true_part2(x) == True })
  |> list.map(fn(x) { x.result })
  |> int.sum
}
