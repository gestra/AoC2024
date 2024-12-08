import day08
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"

pub fn part1_example_test() {
  day08.part1(string.split(example_input, "\n"))
  |> should.equal(14)
}

pub fn part2_example_test() {
  day08.part2(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(34)
}
