import day20.{part1}
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############"

pub fn part1_example_test() {
  part1(string.split(example_input, "\n"))
  |> should.equal(0)
}
// pub fn part2_example_test() {
//   part2(string.split(example_input, "\n"), 7, 12)
//   |> should.equal(-1)
// }
