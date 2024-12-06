import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/otp/task
import gleam/set
import gleam/string
import utils

const input_path = "../../input/day06"

type Lab {
  Lab(
    width: Int,
    height: Int,
    obstructions: set.Set(#(Int, Int)),
    start: #(Int, Int),
  )
}

type Direction {
  Up
  Down
  Left
  Right
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let part1_result = part1(input)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(input)
  io.println("Part 2: " <> int.to_string(part2_result))
}

fn line_objects_loop(
  line: String,
  i: Int,
  acc: #(List(Int), option.Option(Int)),
) -> #(List(Int), option.Option(Int)) {
  case line {
    "" -> acc
    "#" <> rest ->
      line_objects_loop(rest, i + 1, #(list.prepend(acc.0, i), acc.1))
    "^" <> rest -> {
      line_objects_loop(rest, i + 1, #(acc.0, option.Some(i)))
    }
    _ -> line_objects_loop(string.drop_start(line, 1), i + 1, acc)
  }
}

fn line_objects(line: String) -> #(List(Int), option.Option(Int)) {
  line_objects_loop(line, 0, #(list.new(), option.None))
}

fn parse_objects(
  input: List(String),
  y: Int,
  acc: #(set.Set(#(Int, Int)), option.Option(#(Int, Int))),
) -> #(set.Set(#(Int, Int)), option.Option(#(Int, Int))) {
  case input {
    [] -> acc
    [first, ..rest] -> {
      let objects = line_objects(first)
      let obstructions =
        objects.0
        |> list.map(fn(x) { #(x, y) })
        |> set.from_list
        |> set.union(acc.0)
      let start = option.or(acc.1, option.map(objects.1, fn(x) { #(x, y) }))
      parse_objects(rest, y + 1, #(obstructions, start))
    }
  }
}

fn parse_lab(input: List(String)) -> Lab {
  let height = list.length(input)
  let assert Ok(first_line) = list.first(input)
  let width = string.length(first_line)
  let objects = parse_objects(input, 0, #(set.new(), option.None))
  let assert option.Some(start) = objects.1

  Lab(width, height, objects.0, start)
}

fn next_pos(pos: #(Int, Int), direction: Direction) -> #(Int, Int) {
  case direction {
    Up -> #(pos.0, pos.1 - 1)
    Down -> #(pos.0, pos.1 + 1)
    Left -> #(pos.0 - 1, pos.1)
    Right -> #(pos.0 + 1, pos.1)
  }
}

fn turn_right(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn step(
  lab: Lab,
  starting_pos: #(Int, Int),
  starting_direction: Direction,
) -> #(#(Int, Int), Direction) {
  let pos_to_test = next_pos(starting_pos, starting_direction)
  case set.contains(lab.obstructions, pos_to_test) {
    True -> #(starting_pos, turn_right(starting_direction))
    False -> #(pos_to_test, starting_direction)
  }
}

fn move_loop(
  lab: Lab,
  pos: #(Int, Int),
  dir: Direction,
  acc: set.Set(#(Int, Int)),
) -> set.Set(#(Int, Int)) {
  case pos.0 < 0 || pos.1 < 0 || pos.0 >= lab.width || pos.1 >= lab.height {
    True -> acc
    False -> {
      let #(next_pos, next_dir) = step(lab, pos, dir)
      move_loop(lab, next_pos, next_dir, set.insert(acc, pos))
    }
  }
}

fn is_in_loop(
  lab: Lab,
  pos: #(Int, Int),
  dir: Direction,
  acc: set.Set(#(Int, Int, Direction)),
) -> Bool {
  case pos.0 < 0 || pos.1 < 0 || pos.0 >= lab.width || pos.1 >= lab.height {
    True -> False
    False -> {
      case set.contains(acc, #(pos.0, pos.1, dir)) {
        True -> True
        False -> {
          let #(next_pos, next_dir) = step(lab, pos, dir)
          is_in_loop(
            lab,
            next_pos,
            next_dir,
            set.insert(acc, #(pos.0, pos.1, dir)),
          )
        }
      }
    }
  }
}

fn gen_loop(lab: Lab, x: Int, y: Int, acc: List(Lab)) -> List(Lab) {
  case y >= lab.height {
    True -> acc
    False -> {
      case x >= lab.width {
        True -> gen_loop(lab, 0, y + 1, acc)
        False -> {
          case #(x, y) == lab.start || set.contains(lab.obstructions, #(x, y)) {
            True -> gen_loop(lab, x + 1, y, acc)
            False ->
              gen_loop(
                lab,
                x + 1,
                y,
                list.prepend(
                  acc,
                  Lab(
                    ..lab,
                    obstructions: set.insert(lab.obstructions, #(x, y)),
                  ),
                ),
              )
          }
        }
      }
    }
  }
}

fn generate_possibilities(lab: Lab) -> List(Lab) {
  gen_loop(lab, 0, 0, list.new())
}

pub fn part1(input: List(String)) -> Int {
  let lab = parse_lab(input)

  move_loop(lab, lab.start, Up, set.new())
  |> set.size
}

pub fn part2(input: List(String)) -> Int {
  parse_lab(input)
  |> generate_possibilities()
  |> list.map(fn(l) {
    task.async(fn() { is_in_loop(l, l.start, Up, set.new()) })
  })
  |> list.map(fn(t) { task.await_forever(t) })
  |> list.count(fn(x) { x == True })
}
