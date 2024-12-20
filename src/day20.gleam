import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import utils

const input_path = "../../input/day20"

type Pos {
  Pos(x: Int, y: Int)
}

type Cheat {
  Cheat(start: Pos, end: Pos)
}

type Map {
  Map(track: Set(Pos), start: Pos, end: Pos)
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))
}

pub fn part1(input: List(String)) -> Int {
  let map = parse_input(input)
  let distances = distances_from_goal(map)
  let cheats =
    all_cheats([map.start, ..set.to_list(map.track)], distances, list.new())

  cheats
  |> list.group(fn(x) { x.1 })
  |> dict.to_list
  |> list.filter(fn(x) { x.0 >= 100 })
  |> list.map(fn(x) { list.length(x.1) })
  |> int.sum
}

fn parse_input_line(
  line: String,
  x: Int,
  y: Int,
  track_acc: Set(Pos),
  start_acc: Option(Pos),
  end_acc: Option(Pos),
) -> #(Set(Pos), Option(Pos), Option(Pos)) {
  case string.pop_grapheme(line) {
    Error(_) -> #(track_acc, start_acc, end_acc)
    Ok(#(c, rest)) if c == "." ->
      parse_input_line(
        rest,
        x + 1,
        y,
        set.insert(track_acc, Pos(x, y)),
        start_acc,
        end_acc,
      )
    Ok(#(c, rest)) if c == "S" ->
      parse_input_line(rest, x + 1, y, track_acc, Some(Pos(x, y)), end_acc)
    Ok(#(c, rest)) if c == "E" ->
      parse_input_line(rest, x + 1, y, track_acc, start_acc, Some(Pos(x, y)))
    Ok(#(_, rest)) ->
      parse_input_line(rest, x + 1, y, track_acc, start_acc, end_acc)
  }
}

fn parse_input_loop(input: List(String), y: Int, acc: Map) -> Map {
  case input {
    [] -> acc
    [line, ..rest] -> {
      let #(track, start, end) =
        parse_input_line(line, 0, y, acc.track, None, None)
      parse_input_loop(
        rest,
        y + 1,
        Map(
          track: track,
          start: case start {
            Some(p) -> p
            None -> acc.start
          },
          end: case end {
            Some(p) -> p
            None -> acc.end
          },
        ),
      )
    }
  }
}

fn parse_input(input: List(String)) -> Map {
  parse_input_loop(
    input,
    0,
    Map(track: set.new(), start: Pos(-1, -1), end: Pos(-1, -1)),
  )
}

fn next_pos(map: Map, pos: Pos, came_from: Pos) -> Pos {
  let assert Ok(p) =
    [
      Pos(pos.x - 1, pos.y),
      Pos(pos.x + 1, pos.y),
      Pos(pos.x, pos.y - 1),
      Pos(pos.x, pos.y + 1),
    ]
    |> list.find(fn(x) {
      x != came_from && { set.contains(map.track, x) || x == map.end }
    })

  p
}

fn distances_loop(
  map: Map,
  pos: Pos,
  came_from: Pos,
  dist: Int,
  acc: Dict(Pos, Int),
) -> Dict(Pos, Int) {
  case pos == map.end {
    True -> dict.insert(acc, pos, 0)
    False -> {
      let next = next_pos(map, pos, came_from)
      distances_loop(map, next, pos, dist - 1, dict.insert(acc, pos, dist))
    }
  }
}

fn distances_from_goal(map: Map) -> Dict(Pos, Int) {
  distances_loop(
    map,
    next_pos(map, map.start, Pos(-1, -1)),
    map.start,
    set.size(map.track),
    dict.from_list([#(map.start, set.size(map.track) + 1)]),
  )
}

fn cheat_saves(
  cheat: Cheat,
  origin: Pos,
  distances: Dict(Pos, Int),
) -> Result(Int, Nil) {
  case dict.get(distances, cheat.end), dict.get(distances, origin) {
    Ok(e), Ok(s) if e < s + 2 -> Ok(s - e - 2)
    _, _ -> Error(Nil)
  }
}

fn all_cheats(
  positions: List(Pos),
  distances: Dict(Pos, Int),
  acc: List(#(Cheat, Int)),
) -> List(#(Cheat, Int)) {
  case positions {
    [] -> acc
    [pos, ..rest] -> {
      let acc =
        [
          Cheat(Pos(pos.x - 1, pos.y), Pos(pos.x - 2, pos.y)),
          Cheat(Pos(pos.x + 1, pos.y), Pos(pos.x + 2, pos.y)),
          Cheat(Pos(pos.x, pos.y - 1), Pos(pos.x, pos.y - 2)),
          Cheat(Pos(pos.x, pos.y + 1), Pos(pos.x, pos.y + 2)),
        ]
        |> list.map(fn(c) { #(c, cheat_saves(c, pos, distances)) })
        |> list.fold(acc, fn(a, c) {
          case c.1 {
            Ok(n) -> list.prepend(a, #(c.0, n))
            _ -> a
          }
        })
      all_cheats(rest, distances, acc)
    }
  }
}
