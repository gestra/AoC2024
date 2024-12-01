import gleam/int
import gleam/io
import utils

const input_path = "../../input/day01"

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

pub fn part1(input: List(String)) -> Int {
  todo
}

pub fn part2(input: List(String)) -> Int {
  todo
}
