import day09
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "2333133121414131402"

pub fn part1_example_test() {
  day09.part1(example_input)
  |> should.equal(1928)
}

pub fn part2_example_test() {
  day09.part2(example_input)
  |> should.equal(2858)
}
