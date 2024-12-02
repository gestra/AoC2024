import day02
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn part1_example_test() {
  day02.part1(string.split(example_input, "\n"))
  |> should.equal(2)
}

pub fn part2_example_test() {
  day02.part2(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(4)
}
