import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

const input_path = "../../input/day04"

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn horizontal_hits(line: String, acc: Int) -> Int {
  case line {
    "" -> acc
    "XMAS" <> _ | "SAMX" <> _ ->
      horizontal_hits(string.drop_start(line, 3), acc + 1)
    _ -> horizontal_hits(string.drop_start(line, 1), acc)
  }
}

fn vertical_hits_lines(
  l1: String,
  l2: String,
  l3: String,
  l4: String,
  acc: Int,
) -> Int {
  case string.first(l1), string.first(l2), string.first(l3), string.first(l4) {
    Ok("X"), Ok("M"), Ok("A"), Ok("S") | Ok("S"), Ok("A"), Ok("M"), Ok("X") ->
      vertical_hits_lines(
        string.drop_start(l1, 1),
        string.drop_start(l2, 1),
        string.drop_start(l3, 1),
        string.drop_start(l4, 1),
        acc + 1,
      )
    Error(_), _, _, _ -> acc
    _, _, _, _ ->
      vertical_hits_lines(
        string.drop_start(l1, 1),
        string.drop_start(l2, 1),
        string.drop_start(l3, 1),
        string.drop_start(l4, 1),
        acc,
      )
  }
}

fn vertical_hits(lines: List(String), acc: Int) -> Int {
  case list.take(lines, 4) {
    [l1, l2, l3, l4] -> {
      let hits = vertical_hits_lines(l1, l2, l3, l4, 0)
      vertical_hits(list.drop(lines, 1), acc + hits)
    }
    _ -> acc
  }
}

fn diagonal_hits_lines(
  l1: String,
  l2: String,
  l3: String,
  l4: String,
  acc: Int,
) -> Int {
  let g1 = string.to_graphemes(l1)
  let g2 = string.to_graphemes(l2)
  let g3 = string.to_graphemes(l3)
  let g4 = string.to_graphemes(l4)

  let hits1 = case g1, g2, g3, g4 {
    ["X", ..], [_, "M", ..], [_, _, "A", ..], [_, _, _, "S", ..]
    | ["S", ..], [_, "A", ..], [_, _, "M", ..], [_, _, _, "X", ..]
    -> 1
    _, _, _, _ -> 0
  }

  let hits2 = case g1, g2, g3, g4 {
    [_, _, _, "X", ..], [_, _, "M", ..], [_, "A", ..], ["S", ..]
    | [_, _, _, "S", ..], [_, _, "A", ..], [_, "M", ..], ["X", ..]
    -> 1
    _, _, _, _ -> 0
  }

  case g1, g2, g3, g4 {
    [_, _, _], _, _, _ -> acc
    _, _, _, _ ->
      diagonal_hits_lines(
        string.drop_start(l1, 1),
        string.drop_start(l2, 1),
        string.drop_start(l3, 1),
        string.drop_start(l4, 1),
        acc + hits1 + hits2,
      )
  }
}

fn diagonal_hits(lines: List(String), acc: Int) -> Int {
  case list.take(lines, 4) {
    [l1, l2, l3, l4] -> {
      let hits = diagonal_hits_lines(l1, l2, l3, l4, 0)
      diagonal_hits(list.drop(lines, 1), acc + hits)
    }
    _ -> acc
  }
}

fn mas_hits_lines(l1: String, l2: String, l3: String, acc: Int) -> Int {
  let g1 = string.to_graphemes(l1)
  let g2 = string.to_graphemes(l2)
  let g3 = string.to_graphemes(l3)

  case g1, g2, g3 {
    [_, _], _, _ -> acc
    ["M", _, "M", ..], [_, "A", ..], ["S", _, "S", ..]
    | ["M", _, "S", ..], [_, "A", ..], ["M", _, "S", ..]
    | ["S", _, "S", ..], [_, "A", ..], ["M", _, "M", ..]
    | ["S", _, "M", ..], [_, "A", ..], ["S", _, "M", ..]
    ->
      mas_hits_lines(
        string.drop_start(l1, 1),
        string.drop_start(l2, 1),
        string.drop_start(l3, 1),
        acc + 1,
      )
    _, _, _ ->
      mas_hits_lines(
        string.drop_start(l1, 1),
        string.drop_start(l2, 1),
        string.drop_start(l3, 1),
        acc,
      )
  }
}

fn mas_hits(lines: List(String), acc: Int) -> Int {
  case list.take(lines, 3) {
    [l1, l2, l3] -> {
      let hits = mas_hits_lines(l1, l2, l3, 0)
      mas_hits(list.drop(lines, 1), acc + hits)
    }
    _ -> acc
  }
}

pub fn part1(input: List(String)) -> Int {
  let horizontal =
    input
    |> list.map(fn(x) { horizontal_hits(x, 0) })
    |> int.sum
  let vertical = vertical_hits(input, 0)
  let diagonal = diagonal_hits(input, 0)

  horizontal + vertical + diagonal
}

pub fn part2(input: List(String)) -> Int {
  mas_hits(input, 0)
}
