import day12
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"

pub fn part1_example_test() {
  day12.part1(string.split(example_input, "\n"))
  |> should.equal(1930)
}

pub fn part2_example_test() {
  day12.part2(string.split(example_input, "\n"))
  |> should.equal(1206)
}
