import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/pairing_heap
import gleamy/priority_queue
import utils

const input_path = "../../input/day16"

const turn_weight = 1000

pub type Direction {
  North
  South
  East
  West
}

pub type Node {
  Node(x: Int, y: Int, direction: Direction)
}

pub type Graph =
  Dict(Node, List(#(Node, Int)))

pub type Map {
  Map(start: #(Int, Int), end: #(Int, Int), walls: Set(#(Int, Int)))
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))
}

pub fn part1(input: List(String)) -> Int {
  let #(graph, map) = parse_input(input)
  let start = Node(map.start.0, map.start.1, East)
  // Direction doesn't matter for goal
  let goal = Node(map.end.0, map.end.1, East)
  let path = a_star(start, goal, graph)
  path_score(path, graph, 0)
}

pub fn parse_input(input: List(String)) -> #(Graph, Map) {
  let map =
    parse_map(input, 0, Map(start: #(-1, -1), end: #(-1, -1), walls: set.new()))
  #(generate_graph(map), map)
}

fn parse_map(input: List(String), y: Int, acc: Map) -> Map {
  case input {
    [] -> acc
    [first, ..rest] -> parse_map(rest, y + 1, parse_map_line(first, 0, y, acc))
  }
}

fn parse_map_line(line: String, x: Int, y: Int, acc: Map) -> Map {
  case string.pop_grapheme(line) {
    Error(_) -> acc
    Ok(#(c, rest)) -> {
      case c {
        "." -> parse_map_line(rest, x + 1, y, acc)
        "#" ->
          parse_map_line(
            rest,
            x + 1,
            y,
            Map(..acc, walls: set.insert(acc.walls, #(x, y))),
          )
        "S" -> parse_map_line(rest, x + 1, y, Map(..acc, start: #(x, y)))
        "E" -> parse_map_line(rest, x + 1, y, Map(..acc, end: #(x, y)))
        _ -> panic as "Unknown character in input"
      }
    }
  }
}

fn neighbors(x: Int, y: Int, dir: Direction) -> List(#(Node, Int)) {
  case dir {
    East -> [
      #(Node(x, y, North), turn_weight),
      #(Node(x, y, South), turn_weight),
      #(Node(x + 1, y, East), 1),
    ]
    South -> [
      #(Node(x, y, East), turn_weight),
      #(Node(x, y, West), turn_weight),
      #(Node(x, y + 1, South), 1),
    ]
    West -> [
      #(Node(x, y, South), turn_weight),
      #(Node(x, y, North), turn_weight),
      #(Node(x - 1, y, West), 1),
    ]
    North -> [
      #(Node(x, y, East), turn_weight),
      #(Node(x, y, West), turn_weight),
      #(Node(x, y - 1, North), 1),
    ]
  }
}

fn generate_graph(map: Map) -> Graph {
  let nodes = [Node(x: map.start.0, y: map.start.1, direction: East)]
  generate_graph_loop(map, nodes, dict.new())
}

fn generate_graph_loop(map: Map, to_check: List(Node), acc: Graph) -> Graph {
  case to_check {
    [] -> acc
    [node, ..rest] -> {
      case dict.has_key(acc, node) {
        False -> {
          let neighbor_nodes =
            neighbors(node.x, node.y, node.direction)
            |> list.filter(fn(n) {
              !set.contains(map.walls, #({ n.0 }.x, { n.0 }.y))
            })
          let new_acc = dict.insert(acc, node, neighbor_nodes)
          let neighbors = neighbor_nodes |> list.map(fn(n) { n.0 })
          generate_graph_loop(map, list.append(rest, neighbors), new_acc)
        }
        True -> generate_graph_loop(map, rest, acc)
      }
    }
  }
}

fn pop_loop(
  open_set: Set(Node),
  scores: List(#(Node, Int)),
) -> #(Node, Set(Node)) {
  case scores {
    [f, ..rest] ->
      case set.contains(open_set, f.0) {
        True -> #(f.0, set.delete(open_set, f.0))
        False -> pop_loop(open_set, rest)
      }
    _ -> panic as "No lowest f_score found"
  }
}

fn a_star(start: Node, goal: Node, graph: Graph) -> List(Node) {
  let h = fn(a: Node) {
    int.absolute_value(a.x - goal.x) + int.absolute_value(a.y - goal.y)
  }
  //let open_set = set.from_list([start])
  let open_set =
    priority_queue.from_list([#(start, h(start))], fn(a, b) {
      int.compare(a.1, b.1)
    })
  let came_from: dict.Dict(Node, Node) = dict.new()
  let g_score = dict.from_list([#(start, 0)])
  let f_score = dict.from_list([#(start, h(start))])

  a_star_loop(open_set, came_from, g_score, f_score, goal, graph, h)
}

fn a_star_loop(
  open_set: pairing_heap.Heap(#(Node, Int)),
  came_from: dict.Dict(Node, Node),
  g_score: dict.Dict(Node, Int),
  f_score: dict.Dict(Node, Int),
  goal: Node,
  graph: Graph,
  h: fn(Node) -> Int,
) -> List(Node) {
  case priority_queue.pop(open_set) {
    Ok(#(current, new_open_set)) -> {
      case { current.0 }.x == goal.x && { current.0 }.y == goal.y {
        True -> reconstruct_path(came_from, current.0, [current.0])
        False -> {
          case dict.get(graph, current.0) {
            Ok(neighbors) -> {
              let #(open_set, came_from, g_score, f_score) =
                process_neighbors(
                  current.0,
                  neighbors,
                  new_open_set,
                  came_from,
                  g_score,
                  f_score,
                  h,
                )
              a_star_loop(open_set, came_from, g_score, f_score, goal, graph, h)
            }
            _ -> panic
          }
        }
      }
    }
    _ -> panic as "Empty open_set"
  }
}

fn process_neighbors(
  current: Node,
  neighbors: List(#(Node, Int)),
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
        + n.1
      let neighbor_g_score =
        result.unwrap(dict.get(g_score, n.0), 1_000_000_000_000_000_000_000)
      case tentative_g_score < neighbor_g_score {
        True -> {
          let came_from = dict.insert(came_from, n.0, current)
          let g_score = dict.insert(g_score, n.0, tentative_g_score)
          let f_score = dict.insert(f_score, n.0, tentative_g_score + h(n.0))
          let open_set = case
            priority_queue.to_list(open_set) |> list.any(fn(x) { x.0 == n.0 })
          {
            False ->
              priority_queue.push(open_set, #(n.0, tentative_g_score + h(n.0)))
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

fn path_score(path: List(Node), graph: Graph, acc: Int) -> Int {
  case path {
    [] | [_] -> acc
    [f, s, ..r] ->
      case dict.get(graph, f) {
        Ok(neighbors) ->
          case list.find(neighbors, fn(x) { x.0 == s }) {
            Ok(n) -> path_score([s, ..r], graph, acc + n.1)
            _ -> panic
          }
        _ -> panic
      }
  }
}
