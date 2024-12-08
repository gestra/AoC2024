import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils

const input_path = "../../input/day08"

type Map {
  Map(width: Int, height: Int, antennas: dict.Dict(String, List(#(Int, Int))))
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_map_line(
  line: String,
  x: Int,
  acc: List(#(String, Int)),
) -> List(#(String, Int)) {
  case string.pop_grapheme(line) {
    Error(_) -> acc
    Ok(#(".", rest)) -> parse_map_line(rest, x + 1, acc)
    Ok(#(a, rest)) -> {
      parse_map_line(rest, x + 1, list.prepend(acc, #(a, x)))
    }
  }
}

fn parse_map_loop(
  input: List(String),
  y: Int,
  acc: dict.Dict(String, List(#(Int, Int))),
) -> dict.Dict(String, List(#(Int, Int))) {
  case input {
    [] -> acc
    [first, ..rest] -> {
      let new_acc =
        parse_map_line(first, 0, list.new())
        |> list.fold(acc, fn(prev, antenna) {
          let d =
            dict.get(prev, antenna.0)
            |> result.unwrap(list.new())
            |> list.prepend(#(antenna.1, y))
          dict.insert(prev, antenna.0, d)
        })
      parse_map_loop(rest, y + 1, new_acc)
    }
  }
}

fn parse_map(input: List(String)) -> Map {
  let height = list.length(input)
  let width = case list.first(input) {
    Ok(line) -> string.length(line)
    _ -> panic as "No first line in list"
  }

  let antennas = parse_map_loop(input, 0, dict.new())

  Map(width, height, antennas)
}

fn antinode_locations(
  a: #(Int, Int),
  b: #(Int, Int),
) -> #(#(Int, Int), #(Int, Int)) {
  let x_diff = int.absolute_value(a.0 - b.0)
  let y_diff = int.absolute_value(a.1 - b.1)

  case a.0 < b.0, a.1 < b.1 {
    True, True -> #(#(a.0 - x_diff, a.1 - y_diff), #(b.0 + x_diff, b.1 + y_diff))
    True, False -> #(#(a.0 - x_diff, a.1 + y_diff), #(
      b.0 + x_diff,
      b.1 - y_diff,
    ))
    False, False -> #(#(b.0 - x_diff, b.1 - y_diff), #(
      a.0 + x_diff,
      a.1 + y_diff,
    ))
    False, True -> #(#(b.0 - x_diff, b.1 + y_diff), #(
      a.0 + x_diff,
      a.1 - y_diff,
    ))
  }
}

fn harmonics_loop(
  start: #(Int, Int),
  max_x: Int,
  max_y: Int,
  x_diff: Int,
  y_diff: Int,
  acc: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  let new_x = start.0 + x_diff
  let new_y = start.1 + y_diff

  case new_x < 0 || new_y < 0 || new_x >= max_x || new_y >= max_y {
    True -> acc
    False ->
      harmonics_loop(
        #(new_x, new_y),
        max_x,
        max_y,
        x_diff,
        y_diff,
        list.prepend(acc, #(new_x, new_y)),
      )
  }
}

fn antinode_locations_harmonics(
  a: #(Int, Int),
  b: #(Int, Int),
  max_x: Int,
  max_y: Int,
) -> List(#(Int, Int)) {
  let x_diff = int.absolute_value(a.0 - b.0)
  let y_diff = int.absolute_value(a.1 - b.1)

  case a.0 < b.0, a.1 < b.1 {
    True, True ->
      list.append(
        harmonics_loop(a, max_x, max_y, -x_diff, -y_diff, [a, b]),
        harmonics_loop(b, max_x, max_y, x_diff, y_diff, list.new()),
      )
    True, False ->
      list.append(
        harmonics_loop(a, max_x, max_y, -x_diff, y_diff, [a, b]),
        harmonics_loop(b, max_x, max_y, x_diff, -y_diff, list.new()),
      )
    False, False ->
      list.append(
        harmonics_loop(a, max_x, max_y, x_diff, y_diff, [a, b]),
        harmonics_loop(b, max_x, max_y, -x_diff, -y_diff, list.new()),
      )
    False, True ->
      list.append(
        harmonics_loop(a, max_x, max_y, x_diff, -y_diff, [a, b]),
        harmonics_loop(b, max_x, max_y, -x_diff, y_diff, list.new()),
      )
  }
}

pub fn part1(input: List(String)) -> Int {
  let map = parse_map(input)

  map.antennas
  |> dict.values
  |> list.flat_map(fn(x) {
    list.combination_pairs(x)
    |> list.flat_map(fn(y) {
      let nodes = antinode_locations(y.0, y.1)
      [nodes.0, nodes.1]
    })
  })
  |> list.filter(fn(x) {
    x.0 >= 0 && x.0 < map.width && x.1 >= 0 && x.1 < map.height
  })
  |> list.unique
  |> list.length
}

pub fn part2(input: List(String)) -> Int {
  let map = parse_map(input)

  map.antennas
  |> dict.values
  |> list.flat_map(fn(x) {
    list.combination_pairs(x)
    |> list.flat_map(fn(y) {
      antinode_locations_harmonics(y.0, y.1, map.width, map.height)
    })
  })
  |> list.unique
  |> list.length
}
