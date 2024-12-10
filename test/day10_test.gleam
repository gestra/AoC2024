import day10
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"

pub fn part1_example_test() {
  day10.part1(string.split(example_input, "\n"))
  |> should.equal(36)
}

pub fn part2_example_test() {
  day10.part2(string.split(example_input, "\n"))
  |> should.equal(81)
}
