import day03
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const example_input2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part1_example_test() {
  day03.part1(example_input1)
  |> should.equal(161)
}

pub fn part2_example_test() {
  day03.part2(example_input2)
  |> should.equal(48)
}
