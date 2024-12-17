import day17.{part1}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"

pub fn part1_example_test() {
  part1(example_input)
  |> should.equal("4,6,3,5,6,3,5,2,1,0")
}
