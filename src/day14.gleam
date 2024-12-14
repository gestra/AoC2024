import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import utils

const input_path = "../../input/day14"

const p2_iterations = 10_000

pub type Robot {
  Robot(pos: #(Int, Int), vel: #(Int, Int))
}

pub fn main() {
  let input = utils.read_input_file(input_path)

  let robots = parse_input(input)

  let part1_result = part1(robots, 101, 103)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(robots, 101, 103)
  io.println("Part 2: " <> int.to_string(part2_result))
}

pub fn part1(robots: List(Robot), width: Int, height: Int) -> Int {
  robots
  |> move_robots_n_times(width, height, 100)
  |> safety_factor(width, height)
}

pub fn part2(robots: List(Robot), width: Int, height: Int) -> Int {
  robots
  |> move_robots_n_times_print(width, height, p2_iterations)
  0
}

fn parse_input_loop(
  input: List(String),
  re: regexp.Regexp,
  acc: List(Robot),
) -> List(Robot) {
  case input {
    [] -> acc
    [first, ..rest] -> {
      let matches = regexp.scan(re, first)
      case matches {
        [m] -> {
          case m.submatches {
            [
              option.Some(posx_str),
              option.Some(posy_str),
              option.Some(velx_str),
              option.Some(vely_str),
            ] -> {
              let assert Ok(posx) = int.parse(posx_str)
              let assert Ok(posy) = int.parse(posy_str)
              let assert Ok(velx) = int.parse(velx_str)
              let assert Ok(vely) = int.parse(vely_str)
              let new_robot = Robot(pos: #(posx, posy), vel: #(velx, vely))
              parse_input_loop(rest, re, list.prepend(acc, new_robot))
            }
            _ -> panic as "Submatches fail"
          }
        }
        _ -> panic as "Regexp fail"
      }
    }
  }
}

pub fn parse_input(input: List(String)) -> List(Robot) {
  let assert Ok(re) =
    regexp.from_string("p=([0-9]+),([0-9]+) v=(-?[0-9]+),(-?[0-9]+)")
  parse_input_loop(input, re, list.new())
}

fn move(robot: Robot, width: Int, height: Int) -> Robot {
  let assert Ok(newx) = int.modulo(robot.pos.0 + robot.vel.0, width)
  let assert Ok(newy) = int.modulo(robot.pos.1 + robot.vel.1, height)
  Robot(..robot, pos: #(newx, newy))
}

fn move_robots_n_times(
  robots: List(Robot),
  width: Int,
  height: Int,
  times: Int,
) -> List(Robot) {
  case times {
    0 -> robots
    _ ->
      move_robots_n_times(
        list.map(robots, fn(x) { move(x, width, height) }),
        width,
        height,
        times - 1,
      )
  }
}

fn move_robots_n_times_print(
  robots: List(Robot),
  width: Int,
  height: Int,
  times: Int,
) -> List(Robot) {
  case times {
    0 -> robots
    _ -> {
      io.println("Iteration " <> int.to_string(p2_iterations - times))
      io.print(generate_map(robots, width, height))
      move_robots_n_times_print(
        list.map(robots, fn(x) { move(x, width, height) }),
        width,
        height,
        times - 1,
      )
    }
  }
}

fn safety_factor(robots: List(Robot), width: Int, height: Int) -> Int {
  let top_left =
    robots
    |> list.filter(fn(r) { r.pos.0 < width / 2 && r.pos.1 < height / 2 })
    |> list.length
  let top_right =
    robots
    |> list.filter(fn(r) { r.pos.0 > width / 2 && r.pos.1 < height / 2 })
    |> list.length
  let bottom_left =
    robots
    |> list.filter(fn(r) { r.pos.0 < width / 2 && r.pos.1 > height / 2 })
    |> list.length
  let bottom_right =
    robots
    |> list.filter(fn(r) { r.pos.0 > width / 2 && r.pos.1 > height / 2 })
    |> list.length

  top_left * top_right * bottom_left * bottom_right
}

fn generate_line(
  robots: List(Robot),
  width: Int,
  x: Int,
  y: Int,
  acc: String,
) -> String {
  case x {
    _ if x == width -> acc
    _ -> {
      let c = case list.any(robots, fn(r) { r.pos.0 == x && r.pos.1 == y }) {
        True -> "*"
        False -> " "
      }
      generate_line(robots, width, x + 1, y, string.append(acc, c))
    }
  }
}

fn generate_lines(
  robots: List(Robot),
  width: Int,
  height: Int,
  y: Int,
  acc: String,
) -> String {
  case y {
    _ if y == height -> acc
    _ -> {
      let new_line = generate_line(robots, width, 0, y, "") <> "\n"
      generate_lines(robots, width, height, y + 1, string.append(acc, new_line))
    }
  }
}

fn generate_map(robots: List(Robot), width: Int, height: Int) -> String {
  generate_lines(robots, width, height, 0, "")
}
