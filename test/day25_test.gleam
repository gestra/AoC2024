import day25.{part1}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example_input = "#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####"

pub fn part1_example_test() {
  part1(example_input)
  |> should.equal(3)
}
