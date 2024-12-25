import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

const input_path = "../../input/day25"

type Type {
  Lock
  Key
}

type Schematic =
  #(Int, Int, Int, Int, Int)

pub fn main() {
  let input = utils.read_input_file_string(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))
}

pub fn part1(input: String) -> Int {
  let #(locks, keys) =
    input
    |> string.split("\n\n")
    |> list.map(fn(x) { string.split(x, "\n") })
    |> list.map(parse)
    |> list.partition(fn(x) {
      case x.0 {
        Lock -> True
        Key -> False
      }
    })
  let locks =
    locks
    |> list.map(fn(x) { x.1 })
  let keys =
    keys
    |> list.map(fn(x) { x.1 })

  locks
  |> list.map(fn(x) { try_keys(x, keys, 0) })
  |> int.sum
}

fn try_keys(lock: Schematic, keys: List(Schematic), acc: Int) -> Int {
  case keys {
    [] -> acc
    [key, ..rest] -> {
      case
        lock.0 + key.0 > 5
        || lock.1 + key.1 > 5
        || lock.2 + key.2 > 5
        || lock.3 + key.3 > 5
        || lock.4 + key.4 > 5
      {
        True -> try_keys(lock, rest, acc)
        False -> try_keys(lock, rest, acc + 1)
      }
    }
  }
}

fn parse_line(
  input: String,
  i: Int,
  acc: #(Type, Schematic),
) -> #(Type, Schematic) {
  case input {
    "" -> acc
    "." <> rest -> parse_line(rest, i + 1, acc)
    "#" <> rest -> {
      let acc = case i {
        0 -> #(acc.0, #(acc.1.0 + 1, acc.1.1, acc.1.2, acc.1.3, acc.1.4))
        1 -> #(acc.0, #(acc.1.0, acc.1.1 + 1, acc.1.2, acc.1.3, acc.1.4))
        2 -> #(acc.0, #(acc.1.0, acc.1.1, acc.1.2 + 1, acc.1.3, acc.1.4))
        3 -> #(acc.0, #(acc.1.0, acc.1.1, acc.1.2, acc.1.3 + 1, acc.1.4))
        4 -> #(acc.0, #(acc.1.0, acc.1.1, acc.1.2, acc.1.3, acc.1.4 + 1))
        _ -> panic as "Index too high"
      }
      parse_line(rest, i + 1, acc)
    }
    _ -> panic as "Unknown character"
  }
}

fn parse_loop(
  input: List(String),
  acc: #(Type, Schematic),
) -> #(Type, Schematic) {
  case input {
    [] -> acc
    [first, ..rest] -> {
      let acc = parse_line(first, 0, acc)
      parse_loop(rest, acc)
    }
  }
}

fn parse(input: List(String)) -> #(Type, Schematic) {
  let assert Ok(#(line, rest)) = list.pop(input, fn(_) { True })
  let schem = case line {
    "#####" -> #(Lock, #(0, 0, 0, 0, 0))
    "....." -> #(Key, #(-1, -1, -1, -1, -1))
    _ -> panic as "Don't know if key or lock"
  }

  parse_loop(rest, schem)
}
