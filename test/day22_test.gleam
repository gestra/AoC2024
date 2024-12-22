import day22.{part1}
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "1
10
100
2024"

pub fn part1_example_test() {
  part1(string.split(example_input, "\n"))
  |> should.equal(37_327_623)
}
