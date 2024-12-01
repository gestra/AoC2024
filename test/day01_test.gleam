import day01
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn part1_example_test() {
  day01.part1(string.split(example_input, "\n"))
  |> should.equal(11)
}

pub fn part2_example_test() {
  day01.part2(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(31)
}
