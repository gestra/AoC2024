import gleam/int
import gleam/io
import gleam/list
import utils

const input_path = "../../input/day22"

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))
}

pub fn part1(input: List(String)) -> Int {
  input
  |> list.map(fn(x) {
    let assert Ok(n) = int.parse(x)
    n
  })
  |> list.map(fn(x) { loop(2000, x) })
  |> int.sum
}

fn mix(a: Int, b: Int) -> Int {
  int.bitwise_exclusive_or(a, b)
}

fn prune(a: Int) -> Int {
  let assert Ok(res) = int.modulo(a, 16_777_216)
  res
}

fn evolve(number: Int) -> Int {
  let step1 =
    number * 64
    |> mix(number)
    |> prune

  let step2 =
    step1 / 32
    |> mix(step1)
    |> prune

  let step3 =
    step2 * 2048
    |> mix(step2)
    |> prune

  step3
}

fn loop(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> loop(n - 1, evolve(acc))
  }
}
