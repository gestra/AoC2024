import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import utils

const input_path = "../../input/day05"

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn parse_rules(input: List(String)) -> List(#(Int, Int)) {
  input
  |> list.map(fn(x) { string.split(x, "|") })
  |> list.map(fn(x) {
    case list.first(x), list.last(x) {
      Ok(f_str), Ok(l_str) ->
        case int.parse(f_str), int.parse(l_str) {
          Ok(f), Ok(l) -> #(f, l)
          _, _ -> panic as "Error when parsing rules"
        }
      _, _ -> panic as "Error when parsing rules"
    }
  })
}

fn parse_updates(input: List(String)) -> List(List(Int)) {
  input
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.split(",")
    |> list.map(fn(x) {
      let assert Ok(n) = int.parse(x)
      n
    })
  })
}

fn order_loop(
  current: Int,
  before: List(Int),
  after: List(Int),
  rules: List(#(Int, Int)),
) -> Bool {
  let must_be_after = list.key_filter(rules, current)
  case list.any(must_be_after, fn(x) { list.contains(before, x) }) {
    True -> False
    False ->
      case after {
        [] -> True
        [first, ..rest] ->
          order_loop(first, list.append(before, [current]), rest, rules)
      }
  }
}

fn update_in_right_order(updates: List(Int), rules: List(#(Int, Int))) -> Bool {
  case updates {
    [first, ..rest] -> order_loop(first, list.new(), rest, rules)
    [] -> True
  }
}

fn list_into_dict(l: List(a)) -> dict.Dict(Int, a) {
  list.index_fold(l, dict.new(), fn(acc, item, index) {
    dict.insert(acc, index, item)
  })
}

pub fn part1(input: List(String)) -> Int {
  let #(rules, updates) =
    input
    |> list.split_while(fn(x) { x != "" })
    |> fn(x) { #(parse_rules(x.0), parse_updates(list.drop(x.1, 1))) }

  updates
  |> list.filter(fn(x) { update_in_right_order(x, rules) })
  |> list.map(fn(x) {
    let d = list_into_dict(x)
    let middle_index = list.length(x) / 2
    let assert Ok(middle_value) = dict.get(d, middle_index)
    middle_value
  })
  |> int.sum
}

pub fn part2(input: List(String)) -> Int {
  let #(rules, updates) =
    input
    |> list.split_while(fn(x) { x != "" })
    |> fn(x) { #(parse_rules(x.0), parse_updates(list.drop(x.1, 1))) }

  let comparison_fn = fn(a: Int, b: Int) -> order.Order {
    let must_be_after_a = list.key_filter(rules, a)
    let must_be_after_b = list.key_filter(rules, b)
    case list.any(must_be_after_a, fn(x) { x == b }) {
      True -> order.Lt
      False ->
        case list.any(must_be_after_b, fn(x) { x == a }) {
          True -> order.Gt
          False -> order.Eq
        }
    }
  }

  updates
  |> list.filter(fn(x) { !update_in_right_order(x, rules) })
  |> list.map(fn(x) { list.sort(x, comparison_fn) })
  |> list.map(fn(x) {
    let d = list_into_dict(x)
    let middle_index = list.length(x) / 2
    let assert Ok(middle_value) = dict.get(d, middle_index)
    middle_value
  })
  |> int.sum
}
