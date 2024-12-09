import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

const input_path = "../../input/day09"

type Block {
  File(id: Int)
  Empty
}

pub fn main() {
  let input = utils.read_input_file_string(input_path) |> string.trim

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_loop(
  input: String,
  is_file: Bool,
  file_id: Int,
  acc: List(Block),
) -> List(Block) {
  case string.pop_grapheme(input) {
    Ok(#(first, rest)) -> {
      let b = case is_file {
        True -> File(file_id)
        False -> Empty
      }
      let file_to_insert = case int.parse(first) {
        Ok(n) ->
          case n {
            0 -> []
            1 -> [b]
            2 -> [b, b]
            3 -> [b, b, b]
            4 -> [b, b, b, b]
            5 -> [b, b, b, b, b]
            6 -> [b, b, b, b, b, b]
            7 -> [b, b, b, b, b, b, b]
            8 -> [b, b, b, b, b, b, b, b]
            9 -> [b, b, b, b, b, b, b, b, b]
            _ -> panic as "Too high a number"
          }
        _ -> panic as "Could not parse number"
      }
      let next_id = case is_file {
        True -> file_id + 1
        False -> file_id
      }
      parse_loop(rest, !is_file, next_id, list.append(acc, file_to_insert))
    }
    _ -> acc
  }
}

fn parse_line(input: String) -> List(Block) {
  parse_loop(input, True, 0, list.new())
}

fn compact_loop(
  input: deque.Deque(Block),
  acc: deque.Deque(Block),
) -> deque.Deque(Block) {
  case deque.pop_front(input) {
    Ok(#(first, rest)) -> {
      case first {
        Empty -> {
          case deque.pop_back(rest) {
            Ok(#(last, remaining)) ->
              case last {
                Empty -> compact_loop(deque.push_front(remaining, first), acc)
                File(_) -> compact_loop(remaining, deque.push_back(acc, last))
              }
            _ -> acc
          }
        }
        File(_) -> compact_loop(rest, deque.push_back(acc, first))
      }
    }
    _ -> acc
  }
}

fn compact(input: List(Block)) -> List(Block) {
  input
  |> deque.from_list
  |> fn(x) { compact_loop(x, deque.new()) }
  |> deque.to_list
}

fn checksum_loop(input: List(Block), i: Int, acc: Int) -> Int {
  case input {
    [] -> acc
    [first, ..rest] ->
      case first {
        File(n) -> checksum_loop(rest, i + 1, acc + n * i)
        Empty -> checksum_loop(rest, i + 1, acc)
      }
  }
}

fn checksum(input: List(Block)) -> Int {
  checksum_loop(input, 0, 0)
}

fn insert_into_empty(
  chunks: List(List(Block)),
  to_insert: List(Block),
  acc: deque.Deque(List(Block)),
) -> Result(deque.Deque(List(Block)), Nil) {
  let l = list.length(to_insert)
  let assert Ok(replaced) = list.first(to_insert)
  case chunks {
    [] -> Error(Nil)
    [[a, ..] as span, ..rest] ->
      case a {
        Empty ->
          case list.length(span) >= l {
            True -> {
              Ok(deque.push_back(
                deque.push_back(acc, list.append(to_insert, list.drop(span, l))),
                list.flatten(rest)
                  |> list.map(fn(x) {
                    case x == replaced {
                      True -> Empty
                      False -> x
                    }
                  }),
              ))
            }
            False ->
              insert_into_empty(rest, to_insert, deque.push_back(acc, span))
          }
        File(_) ->
          case a == replaced {
            True -> Error(Nil)
            _ -> insert_into_empty(rest, to_insert, deque.push_back(acc, span))
          }
      }
    _ -> Error(Nil)
  }
}

fn compact_defrag_loop(
  id_to_move: Int,
  acc: List(List(Block)),
) -> List(List(Block)) {
  case id_to_move {
    0 -> acc
    n -> {
      let assert Ok(file) =
        acc
        |> list.filter(fn(x) { list.first(x) == Ok(File(n)) })
        |> list.first

      let new_acc = case insert_into_empty(acc, file, deque.new()) {
        Ok(a) -> {
          a
          |> deque.to_list
          |> list.flatten
          |> list.chunk(fn(x) { x })
        }
        Error(_) -> acc
      }

      compact_defrag_loop(id_to_move - 1, new_acc)
    }
  }
}

fn compact_defrag(input: List(Block)) -> List(Block) {
  let chunks =
    input
    |> list.chunk(fn(x) { x })

  let highest_id = case list.last(input) {
    Ok(File(n)) -> n
    _ -> panic as "Ugly assumptions"
  }

  compact_defrag_loop(highest_id, chunks)
  |> list.flatten
}

pub fn part1(input: String) -> Int {
  parse_line(input)
  |> compact
  |> checksum
}

pub fn part2(input: String) -> Int {
  parse_line(input)
  |> compact_defrag
  |> checksum
}
