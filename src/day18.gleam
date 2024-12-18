import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/pairing_heap
import gleamy/priority_queue
import utils

const input_path = "../../input/day18"

type Map {
  Map(corrupted: Set(Node), size: Int)
}

type Node {
  Node(x: Int, y: Int)
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input, 71, 1024)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input, 71, 1024)
  io.println("Part 2: " <> part2_result)
}

pub fn part1(input: List(String), size: Int, bytes: Int) -> Int {
  let map = parse_input(list.take(input, bytes), size)
  let assert Ok(path) = a_star(Node(0, 0), Node(size - 1, size - 1), map)

  // Starting position doesn't count as a step
  list.length(path) - 1
}

pub fn part2(input: List(String), size: Int, bytes: Int) -> String {
  let map = parse_input(list.take(input, bytes), size)
  let node = part2_loop(map, list.drop(input, bytes))
  int.to_string(node.x) <> "," <> int.to_string(node.y)
}

fn part2_loop(map: Map, input: List(String)) -> Node {
  let assert Ok(#(next_byte, rest_bytes)) = list.pop(input, fn(_) { True })
  let added = coords_to_node(next_byte)
  let map = Map(..map, corrupted: set.insert(map.corrupted, added))
  case a_star(Node(0, 0), Node(map.size - 1, map.size - 1), map) {
    Ok(_) -> part2_loop(map, rest_bytes)
    Error(_) -> added
  }
}

fn coords_to_node(s: String) -> Node {
  let assert Ok(#(x_str, y_str)) = string.split_once(s, ",")
  let assert Ok(x) = int.parse(x_str)
  let assert Ok(y) = int.parse(y_str)
  Node(x, y)
}

fn parse_loop(input: List(String), acc: Set(Node)) -> Set(Node) {
  case input {
    [] -> acc
    [first, ..rest] -> {
      let node = coords_to_node(first)
      parse_loop(rest, set.insert(acc, node))
    }
  }
}

fn parse_input(input: List(String), size: Int) -> Map {
  let corrupted = parse_loop(input, set.new())
  Map(corrupted: corrupted, size: size)
}

fn neigbhbors(node: Node, map: Map) -> List(Node) {
  [
    Node(node.x, node.y - 1),
    Node(node.x, node.y + 1),
    Node(node.x - 1, node.y),
    Node(node.x + 1, node.y),
  ]
  |> list.filter(fn(n) {
    n.x >= 0 && n.y >= 0 && n.x < map.size && n.y < map.size
  })
  |> list.filter(fn(n) { !set.contains(map.corrupted, n) })
}

fn a_star(start: Node, goal: Node, map: Map) -> Result(List(Node), Nil) {
  let h = fn(a: Node) {
    int.absolute_value(a.x - goal.x) + int.absolute_value(a.y - goal.y)
  }
  let open_set =
    priority_queue.from_list([#(start, h(start))], fn(a, b) {
      int.compare(a.1, b.1)
    })
  let came_from: dict.Dict(Node, Node) = dict.new()
  let g_score = dict.from_list([#(start, 0)])
  let f_score = dict.from_list([#(start, h(start))])

  a_star_loop(open_set, came_from, g_score, f_score, goal, map, h)
}

fn a_star_loop(
  open_set: pairing_heap.Heap(#(Node, Int)),
  came_from: dict.Dict(Node, Node),
  g_score: dict.Dict(Node, Int),
  f_score: dict.Dict(Node, Int),
  goal: Node,
  map: Map,
  h: fn(Node) -> Int,
) -> Result(List(Node), Nil) {
  case priority_queue.pop(open_set) {
    Ok(#(#(current, _), new_open_set)) -> {
      case current.x == goal.x && current.y == goal.y {
        True -> Ok(reconstruct_path(came_from, current, [current]))
        False -> {
          let neighbors = neigbhbors(current, map)
          let #(open_set, came_from, g_score, f_score) =
            process_neighbors(
              current,
              neighbors,
              new_open_set,
              came_from,
              g_score,
              f_score,
              h,
            )
          a_star_loop(open_set, came_from, g_score, f_score, goal, map, h)
        }
      }
    }
    _ -> Error(Nil)
  }
}

fn process_neighbors(
  current: Node,
  neighbors: List(Node),
  open_set: pairing_heap.Heap(#(Node, Int)),
  came_from: dict.Dict(Node, Node),
  g_score: dict.Dict(Node, Int),
  f_score: dict.Dict(Node, Int),
  h: fn(Node) -> Int,
) -> #(
  pairing_heap.Heap(#(Node, Int)),
  dict.Dict(Node, Node),
  dict.Dict(Node, Int),
  dict.Dict(Node, Int),
) {
  case neighbors {
    [] -> #(open_set, came_from, g_score, f_score)
    [n, ..rest] -> {
      let tentative_g_score =
        result.unwrap(dict.get(g_score, current), 1_000_000_000_000_000_000_000)
        + 1
      let neighbor_g_score =
        result.unwrap(dict.get(g_score, n), 1_000_000_000_000_000_000_000)
      case tentative_g_score < neighbor_g_score {
        True -> {
          let came_from = dict.insert(came_from, n, current)
          let g_score = dict.insert(g_score, n, tentative_g_score)
          let f_score = dict.insert(f_score, n, tentative_g_score + h(n))
          let open_set = case
            priority_queue.to_list(open_set) |> list.any(fn(x) { x.0 == n })
          {
            False ->
              priority_queue.push(open_set, #(n, tentative_g_score + h(n)))
            True -> open_set
          }

          process_neighbors(
            current,
            rest,
            open_set,
            came_from,
            g_score,
            f_score,
            h,
          )
        }
        False ->
          process_neighbors(
            current,
            rest,
            open_set,
            came_from,
            g_score,
            f_score,
            h,
          )
      }
    }
  }
}

fn reconstruct_path(
  came_from: dict.Dict(Node, Node),
  current: Node,
  acc: List(Node),
) -> List(Node) {
  case dict.get(came_from, current) {
    Ok(n) -> reconstruct_path(came_from, n, list.prepend(acc, n))
    Error(_) -> acc
  }
}
// fn print_line(map: Map, x: Int, y: Int) -> Nil {
//   case x >= map.size {
//     True -> Nil
//     False -> {
//       case set.contains(map.corrupted, Node(x, y)) {
//         True -> io.print("#")
//         False -> io.print(".")
//       }
//       print_line(map, x + 1, y)
//     }
//   }
// }

// fn print_map_loop(map: Map, y: Int) -> Nil {
//   case y >= map.size {
//     True -> Nil
//     False -> {
//       print_line(map, 0, y)
//       io.print("\n")
//       print_map_loop(map, y + 1)
//     }
//   }
// }

// fn print_map(map: Map) -> Nil {
//   print_map_loop(map, 0)
// }
