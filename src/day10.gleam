import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import utils

const input_path = "../../input/day10"

type Map =
  dict.Dict(#(Int, Int), Int)

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_line(line: String, acc: List(Int)) -> List(Int) {
  case string.pop_grapheme(line) {
    Ok(#(c, rest)) -> {
      let assert Ok(n) = int.parse(c)
      parse_line(rest, list.prepend(acc, n))
    }
    Error(_) -> list.reverse(acc)
  }
}

fn parse_map_loop(input: List(String), y: Int, acc: Map) -> Map {
  case input {
    [first, ..rest] -> {
      let new_acc =
        parse_line(first, list.new())
        |> list.index_map(fn(x, i) { #(#(i, y), x) })
        |> dict.from_list
        |> dict.merge(acc)
      parse_map_loop(rest, y + 1, new_acc)
    }
    [] -> acc
  }
}

fn parse_map(input: List(String)) -> Map {
  parse_map_loop(input, 0, dict.new())
}

fn nines_reachable(
  map: Map,
  cur_val: Int,
  pos: #(Int, Int),
  acc: set.Set(#(Int, Int)),
) -> set.Set(#(Int, Int)) {
  [
    #(pos.0 - 1, pos.1),
    #(pos.0 + 1, pos.1),
    #(pos.0, pos.1 - 1),
    #(pos.0, pos.1 + 1),
  ]
  |> list.map(fn(x) {
    case dict.get(map, x) {
      Ok(n) if n == cur_val + 1 && n == 9 -> set.insert(acc, x)
      Ok(n) if n == cur_val + 1 -> nines_reachable(map, cur_val + 1, x, acc)
      _ -> set.new()
    }
  })
  |> list.fold(acc, set.union)
}

fn trailhead_score(map: Map, pos: #(Int, Int)) -> Int {
  nines_reachable(map, 0, pos, set.new())
  |> set.size
}

fn trails_to_nines(map: Map, cur_val: Int, pos: #(Int, Int)) -> Int {
  [
    #(pos.0 - 1, pos.1),
    #(pos.0 + 1, pos.1),
    #(pos.0, pos.1 - 1),
    #(pos.0, pos.1 + 1),
  ]
  |> list.map(fn(x) {
    case dict.get(map, x) {
      Ok(n) if n == cur_val + 1 && n == 9 -> 1
      Ok(n) if n == cur_val + 1 -> trails_to_nines(map, cur_val + 1, x)
      _ -> 0
    }
  })
  |> int.sum
}

fn trailhead_score_trails(map: Map, pos: #(Int, Int)) -> Int {
  trails_to_nines(map, 0, pos)
}

pub fn part1(input: List(String)) -> Int {
  let map = parse_map(input)

  dict.filter(map, fn(_, val) { val == 0 })
  |> dict.keys
  |> list.map(fn(x) { trailhead_score(map, x) })
  |> int.sum
}

pub fn part2(input: List(String)) -> Int {
  let map = parse_map(input)

  dict.filter(map, fn(_, val) { val == 0 })
  |> dict.keys
  |> list.map(fn(x) { trailhead_score_trails(map, x) })
  |> int.sum
}
