import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import utils

const input_path = "../../input/day12"

type Region =
  List(#(Int, Int))

type Map =
  dict.Dict(#(Int, Int), String)

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_line(
  line: String,
  i: Int,
  acc: List(#(Int, String)),
) -> List(#(Int, String)) {
  case string.pop_grapheme(line) {
    Error(_) -> acc
    Ok(#(c, rest)) -> parse_line(rest, i + 1, list.prepend(acc, #(i, c)))
  }
}

fn parse_map_loop(input: List(String), y: Int, acc: Map) -> Map {
  case input {
    [] -> acc
    [first, ..rest] -> {
      let new_acc =
        parse_line(first, 0, list.new())
        |> list.map(fn(plot) { #(#(plot.0, y), plot.1) })
        |> list.fold(acc, fn(a, p) { dict.insert(a, p.0, p.1) })
      parse_map_loop(rest, y + 1, new_acc)
    }
  }
}

fn parse_map(input: List(String)) -> Map {
  parse_map_loop(input, 0, dict.new())
}

fn flood_fill_region(
  map: Map,
  pos: #(Int, Int),
  plant: String,
  acc: set.Set(#(Int, Int)),
) -> set.Set(#(Int, Int)) {
  case dict.get(map, pos) {
    Ok(p) if p == plant -> {
      case !set.contains(acc, pos) {
        True -> {
          let new_acc = set.insert(acc, pos)
          let new_acc =
            set.union(
              acc,
              flood_fill_region(map, #(pos.0 - 1, pos.1), plant, new_acc),
            )
          let new_acc =
            set.union(
              acc,
              flood_fill_region(map, #(pos.0 + 1, pos.1), plant, new_acc),
            )
          let new_acc =
            set.union(
              acc,
              flood_fill_region(map, #(pos.0, pos.1 - 1), plant, new_acc),
            )
          let new_acc =
            set.union(
              acc,
              flood_fill_region(map, #(pos.0, pos.1 + 1), plant, new_acc),
            )
          new_acc
        }
        False -> acc
      }
    }
    _ -> acc
  }
}

fn parse_region_row(
  map: Map,
  x: Int,
  y: Int,
  acc: List(Region),
  already_checked: set.Set(#(Int, Int)),
) -> #(List(Region), set.Set(#(Int, Int))) {
  case set.contains(already_checked, #(x, y)) {
    True -> parse_region_row(map, x + 1, y, acc, already_checked)
    False ->
      case dict.get(map, #(x, y)) {
        Ok(p) -> {
          let region_set = flood_fill_region(map, #(x, y), p, set.new())
          let new_already = set.union(already_checked, region_set)

          parse_region_row(
            map,
            x + 1,
            y,
            list.prepend(acc, set.to_list(region_set)),
            new_already,
          )
        }
        _ -> #(acc, already_checked)
      }
  }
}

fn parse_regions_col(
  map: Map,
  y: Int,
  acc: List(Region),
  already_checked: set.Set(#(Int, Int)),
) -> List(Region) {
  case dict.has_key(map, #(0, y)) {
    True -> {
      let #(regions, checked) =
        parse_region_row(map, 0, y, list.new(), already_checked)
      parse_regions_col(map, y + 1, list.append(regions, acc), checked)
    }
    False -> acc
  }
}

fn parse_regions(input: Map) -> List(Region) {
  parse_regions_col(input, 0, list.new(), set.new())
}

fn perimeter_loop(region: Region, map: Map, acc: Int) -> Int {
  case region {
    [first, ..rest] -> {
      let assert Ok(plant) = dict.get(map, first)
      let perim =
        [
          #(first.0 - 1, first.1),
          #(first.0 + 1, first.1),
          #(first.0, first.1 - 1),
          #(first.0, first.1 + 1),
        ]
        |> list.map(fn(x) {
          case dict.get(map, x) {
            Ok(neighbor) if neighbor == plant -> 0
            _ -> 1
          }
        })
        |> int.sum

      perimeter_loop(rest, map, acc + perim)
    }
    _ -> acc
  }
}

fn perimeter(region: Region, map: Map) -> Int {
  perimeter_loop(region, map, 0)
}

fn price_perimeter(region: Region, map: Map) -> Int {
  list.length(region) * perimeter(region, map)
}

fn up(pos: #(Int, Int)) -> #(Int, Int) {
  #(pos.0, pos.1 - 1)
}

fn down(pos: #(Int, Int)) -> #(Int, Int) {
  #(pos.0, pos.1 + 1)
}

fn left(pos: #(Int, Int)) -> #(Int, Int) {
  #(pos.0 - 1, pos.1)
}

fn right(pos: #(Int, Int)) -> #(Int, Int) {
  #(pos.0 + 1, pos.1)
}

fn corners(region: Region, map: Map, acc: Int) -> Int {
  case region {
    [pos, ..rest] -> {
      let assert Ok(p) = dict.get(map, pos)
      let u = dict.get(map, up(pos))
      let d = dict.get(map, down(pos))
      let l = dict.get(map, left(pos))
      let r = dict.get(map, right(pos))

      let ur = dict.get(map, up(right(pos)))
      let rd = dict.get(map, right(down(pos)))
      let dl = dict.get(map, down(left(pos)))
      let lu = dict.get(map, left(up(pos)))

      let c =
        [
          case u, r {
            Ok(a), Ok(b) if p != a && p != b -> 1
            Ok(a), Error(_) if p != a -> 1
            Error(_), Ok(b) if p != b -> 1
            Error(_), Error(_) -> 1
            _, _ -> 0
          },
          case r, d {
            Ok(a), Ok(b) if p != a && p != b -> 1
            Ok(a), Error(_) if p != a -> 1
            Error(_), Ok(b) if p != b -> 1
            Error(_), Error(_) -> 1
            _, _ -> 0
          },
          case d, l {
            Ok(a), Ok(b) if p != a && p != b -> 1
            Ok(a), Error(_) if p != a -> 1
            Error(_), Ok(b) if p != b -> 1
            Error(_), Error(_) -> 1
            _, _ -> 0
          },
          case l, u {
            Ok(a), Ok(b) if p != a && p != b -> 1
            Ok(a), Error(_) if p != a -> 1
            Error(_), Ok(b) if p != b -> 1
            Error(_), Error(_) -> 1
            _, _ -> 0
          },
          case ur, u, r {
            Ok(a), Ok(b), Ok(c) if a != p && b == p && c == p -> 1
            _, _, _ -> 0
          },
          case rd, r, d {
            Ok(a), Ok(b), Ok(c) if a != p && b == p && c == p -> 1
            _, _, _ -> 0
          },
          case dl, d, l {
            Ok(a), Ok(b), Ok(c) if a != p && b == p && c == p -> 1
            _, _, _ -> 0
          },
          case lu, l, u {
            Ok(a), Ok(b), Ok(c) if a != p && b == p && c == p -> 1
            _, _, _ -> 0
          },
        ]
        |> int.sum
      corners(rest, map, acc + c)
    }
    [] -> acc
  }
}

fn price_corners(region: Region, map: Map) -> Int {
  list.length(region) * corners(region, map, 0)
}

pub fn part1(input: List(String)) -> Int {
  let map =
    input
    |> parse_map

  map
  |> parse_regions
  |> list.map(fn(x) { price_perimeter(x, map) })
  |> int.sum
}

pub fn part2(input: List(String)) -> Int {
  let map =
    input
    |> parse_map

  map
  |> parse_regions
  |> list.map(fn(x) { price_corners(x, map) })
  |> int.sum
}
