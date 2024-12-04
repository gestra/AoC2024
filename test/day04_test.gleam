import day04
import gleam/string
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

pub fn part1_example_test() {
  day04.part1(string.split(example_input, "\n"))
  |> should.equal(18)
}

pub fn part2_example_test() {
  day04.part2(
    example_input
    |> string.split("\n"),
  )
  |> should.equal(9)
}
