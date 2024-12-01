import day01
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = ""

pub fn part1_example_test() {
  day01.part1(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(0)
}

pub fn part2_example_test() {
  day01.part2(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(0)
}
