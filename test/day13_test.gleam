import day13.{parse_machines, part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279"

pub fn part1_example_test() {
  part1(parse_machines(example_input))
  |> should.equal(480)
}

pub fn part2_example_test() {
  part2(parse_machines(example_input))
  |> should.equal(0)
}
