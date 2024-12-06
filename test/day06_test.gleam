import day06
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn part1_example_test() {
  day06.part1(string.split(example_input, "\n"))
  |> should.equal(41)
}

pub fn part2_example_test() {
  day06.part2(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(6)
}
