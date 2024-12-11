import day11
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "125 17"

pub fn part1_example_test() {
  example_input
  |> day11.part1
  |> should.equal(55_312)
}
