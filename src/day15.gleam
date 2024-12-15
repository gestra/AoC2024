import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set
import gleam/string
import utils

const input_path = "../../input/day15"

pub type Direction {
  Up
  Down
  Left
  Right
}

pub type Warehouse {
  Warehouse(
    robot: #(Int, Int),
    boxes: set.Set(#(Int, Int)),
    walls: set.Set(#(Int, Int)),
  )
}

type WideBox =
  #(#(Int, Int), #(Int, Int))

pub type WideWarehouse {
  WideWarehouse(
    robot: #(Int, Int),
    boxes: set.Set(WideBox),
    walls: set.Set(#(Int, Int)),
  )
}

pub fn main() {
  let input =
    input_path
    |> utils.read_input_file_string
    |> string.trim

  let #(warehouse, moves) = parse_input(input)

  let part1_result = part1(warehouse, moves)
  io.println("Part 1: " <> int.to_string(part1_result))

  let part2_result = part2(warehouse, moves)
  io.println("Part 2: " <> int.to_string(part2_result))
}

pub fn part1(warehouse: Warehouse, moves: List(Direction)) -> Int {
  let res = execute_movements(warehouse, moves)
  sum_box_coordinates(set.to_list(res.boxes), 0)
}

pub fn part2(warehouse: Warehouse, moves: List(Direction)) -> Int {
  let new_wh = modify_map(warehouse)
  //io.println(print_warehouse_wide(new_wh, 0, ""))
  //let moved = move_robot_wide(new_wh, Left)

  //io.println(print_warehouse_wide(moved, 0, ""))
  let res = execute_movements_wide(new_wh, moves)
  sum_box_coordinates_wide(set.to_list(res.boxes), 0)
}

fn parse_map_line(
  line: String,
  x: Int,
  acc_walls: List(Int),
  acc_boxes: List(Int),
  acc_robot: Option(Int),
) -> #(List(Int), List(Int), Option(Int)) {
  case string.pop_grapheme(line) {
    Error(_) -> #(acc_walls, acc_boxes, acc_robot)
    Ok(#("#", rest)) ->
      parse_map_line(
        rest,
        x + 1,
        list.prepend(acc_walls, x),
        acc_boxes,
        acc_robot,
      )
    Ok(#("O", rest)) ->
      parse_map_line(
        rest,
        x + 1,
        acc_walls,
        list.prepend(acc_boxes, x),
        acc_robot,
      )
    Ok(#("@", rest)) ->
      parse_map_line(rest, x + 1, acc_walls, acc_boxes, Some(x))
    Ok(#(_, rest)) ->
      parse_map_line(rest, x + 1, acc_walls, acc_boxes, acc_robot)
  }
}

fn parse_map(
  lines: List(String),
  y: Int,
  acc_walls: set.Set(#(Int, Int)),
  acc_boxes: set.Set(#(Int, Int)),
  acc_robot: #(Int, Int),
) -> Warehouse {
  case lines {
    [] -> Warehouse(robot: acc_robot, boxes: acc_boxes, walls: acc_walls)
    [first, ..rest] -> {
      let #(line_walls, line_boxes, line_robot) =
        parse_map_line(first, 0, list.new(), list.new(), None)
      let acc_walls =
        line_walls
        |> list.fold(acc_walls, fn(acc, x) { set.insert(acc, #(x, y)) })
      let acc_boxes =
        line_boxes
        |> list.fold(acc_boxes, fn(acc, x) { set.insert(acc, #(x, y)) })
      let acc_robot = case line_robot {
        None -> acc_robot
        Some(x) -> #(x, y)
      }
      parse_map(rest, y + 1, acc_walls, acc_boxes, acc_robot)
    }
  }
}

fn parse_moves(input: String, acc: List(Direction)) -> List(Direction) {
  case string.pop_grapheme(input) {
    Error(_) -> list.reverse(acc)
    Ok(#("^", rest)) -> parse_moves(rest, list.prepend(acc, Up))
    Ok(#("v", rest)) -> parse_moves(rest, list.prepend(acc, Down))
    Ok(#("<", rest)) -> parse_moves(rest, list.prepend(acc, Left))
    Ok(#(">", rest)) -> parse_moves(rest, list.prepend(acc, Right))
    _ -> panic as "Unknown move"
  }
}

pub fn parse_input(input: String) -> #(Warehouse, List(Direction)) {
  let assert Ok(#(map_input, moves_input)) = string.split_once(input, "\n\n")
  let map =
    parse_map(string.split(map_input, "\n"), 0, set.new(), set.new(), #(0, 0))

  let moves_cleaned =
    moves_input
    |> string.to_graphemes
    |> list.filter(fn(x) { x != "\n" })
    |> string.concat
  let moves = parse_moves(moves_cleaned, list.new())

  #(map, moves)
}

fn slide_boxes(
  warehouse: Warehouse,
  pos: #(Int, Int),
  dir: Direction,
) -> Result(Warehouse, Nil) {
  let next_pos = move(pos, dir)
  case set.contains(warehouse.walls, next_pos) {
    True -> Error(Nil)
    False ->
      case set.contains(warehouse.boxes, next_pos) {
        True ->
          case slide_boxes(warehouse, next_pos, dir) {
            Ok(wh) -> {
              let new_boxes =
                wh.boxes
                |> set.delete(pos)
                |> set.insert(next_pos)
              Ok(Warehouse(..wh, boxes: new_boxes))
            }
            Error(_) -> Error(Nil)
          }
        False -> {
          let new_boxes =
            warehouse.boxes
            |> set.delete(pos)
            |> set.insert(next_pos)
          Ok(Warehouse(..warehouse, boxes: new_boxes))
        }
      }
  }
}

fn move(pos: #(Int, Int), direction: Direction) -> #(Int, Int) {
  case direction {
    Up -> #(pos.0, pos.1 - 1)
    Down -> #(pos.0, pos.1 + 1)
    Left -> #(pos.0 - 1, pos.1)
    Right -> #(pos.0 + 1, pos.1)
  }
}

fn move_robot(warehouse: Warehouse, direction: Direction) -> Warehouse {
  let target_pos = move(warehouse.robot, direction)
  case set.contains(warehouse.walls, target_pos) {
    True -> warehouse
    False ->
      case set.contains(warehouse.boxes, target_pos) {
        True -> {
          case slide_boxes(warehouse, target_pos, direction) {
            Ok(new) -> Warehouse(..new, robot: target_pos)
            Error(_) -> warehouse
          }
        }
        False -> Warehouse(..warehouse, robot: target_pos)
      }
  }
}

fn execute_movements(
  warehouse: Warehouse,
  movements: List(Direction),
) -> Warehouse {
  case movements {
    [] -> warehouse
    [first, ..rest] -> execute_movements(move_robot(warehouse, first), rest)
  }
}

fn wide_box_at_location(
  boxes: set.Set(WideBox),
  pos: #(Int, Int),
) -> Option(WideBox) {
  case
    boxes
    |> set.filter(fn(b) {
      { b.0.0 == pos.0 && b.0.1 == pos.1 }
      || { b.1.0 == pos.0 && b.1.1 == pos.1 }
    })
    |> set.to_list
  {
    [box] -> Some(box)
    [] -> None
    _ -> panic as "Multiple boxes at same location"
  }
}

fn slide_boxes_wide(
  warehouse: WideWarehouse,
  box: WideBox,
  direction: Direction,
) -> Result(WideWarehouse, Nil) {
  let target_poss = #(move(box.0, direction), move(box.1, direction))
  case
    set.contains(warehouse.walls, target_poss.0)
    || set.contains(warehouse.walls, target_poss.1)
  {
    True -> Error(Nil)
    False ->
      case direction {
        Up | Down ->
          case
            wide_box_at_location(warehouse.boxes, target_poss.0),
            wide_box_at_location(warehouse.boxes, target_poss.1)
          {
            Some(a), Some(b) if a == b ->
              case slide_boxes_wide(warehouse, a, direction) {
                Ok(w) -> {
                  let new_boxes =
                    w.boxes
                    |> set.delete(box)
                    |> set.insert(target_poss)
                  Ok(
                    WideWarehouse(
                      ..w,
                      robot: move(warehouse.robot, direction),
                      boxes: new_boxes,
                    ),
                  )
                }
                Error(Nil) -> Error(Nil)
              }
            Some(a), Some(b) ->
              case slide_boxes_wide(warehouse, a, direction) {
                Ok(w1) ->
                  case slide_boxes_wide(w1, b, direction) {
                    Ok(w2) -> {
                      let new_boxes =
                        w2.boxes
                        |> set.delete(box)
                        |> set.insert(target_poss)
                      Ok(
                        WideWarehouse(
                          ..w2,
                          robot: move(warehouse.robot, direction),
                          boxes: new_boxes,
                        ),
                      )
                    }
                    Error(_) -> Error(Nil)
                  }
                Error(_) -> Error(Nil)
              }
            Some(a), None | None, Some(a) ->
              case slide_boxes_wide(warehouse, a, direction) {
                Ok(w1) -> {
                  let new_boxes =
                    w1.boxes
                    |> set.delete(box)
                    |> set.insert(target_poss)
                  Ok(
                    WideWarehouse(
                      ..w1,
                      robot: move(warehouse.robot, direction),
                      boxes: new_boxes,
                    ),
                  )
                }
                Error(Nil) -> Error(Nil)
              }
            None, None -> {
              let new_boxes =
                warehouse.boxes
                |> set.delete(box)
                |> set.insert(target_poss)
              Ok(
                WideWarehouse(
                  ..warehouse,
                  robot: move(warehouse.robot, direction),
                  boxes: new_boxes,
                ),
              )
            }
          }
        Left | Right -> {
          let to_check = case direction {
            Left -> target_poss.0
            Right -> target_poss.1
            _ -> panic as "WTF"
          }
          case wide_box_at_location(warehouse.boxes, to_check) {
            Some(b) ->
              case slide_boxes_wide(warehouse, b, direction) {
                Ok(w) -> {
                  let new_boxes =
                    w.boxes
                    |> set.delete(box)
                    |> set.insert(target_poss)
                  Ok(
                    WideWarehouse(
                      ..w,
                      robot: move(warehouse.robot, direction),
                      boxes: new_boxes,
                    ),
                  )
                }
                Error(Nil) -> Error(Nil)
              }
            None -> {
              let new_boxes =
                warehouse.boxes
                |> set.delete(box)
                |> set.insert(target_poss)
              Ok(
                WideWarehouse(
                  ..warehouse,
                  robot: move(warehouse.robot, direction),
                  boxes: new_boxes,
                ),
              )
            }
          }
        }
      }
  }
}

fn move_robot_wide(
  warehouse: WideWarehouse,
  direction: Direction,
) -> WideWarehouse {
  let target_pos = move(warehouse.robot, direction)
  case set.contains(warehouse.walls, target_pos) {
    True -> warehouse
    False ->
      case wide_box_at_location(warehouse.boxes, target_pos) {
        Some(box) -> {
          case slide_boxes_wide(warehouse, box, direction) {
            Ok(new) -> WideWarehouse(..new, robot: target_pos)
            Error(_) -> warehouse
          }
        }
        None -> WideWarehouse(..warehouse, robot: target_pos)
      }
  }
}

fn execute_movements_wide(
  warehouse: WideWarehouse,
  movements: List(Direction),
) -> WideWarehouse {
  case movements {
    [] -> warehouse
    [first, ..rest] ->
      execute_movements_wide(move_robot_wide(warehouse, first), rest)
  }
}

fn sum_box_coordinates(boxes: List(#(Int, Int)), acc: Int) -> Int {
  case boxes {
    [] -> acc
    [#(x, y), ..rest] -> sum_box_coordinates(rest, acc + 100 * y + x)
  }
}

fn sum_box_coordinates_wide(boxes: List(WideBox), acc: Int) -> Int {
  case boxes {
    [] -> acc
    [#(#(x1, y1), #(_, _)), ..rest] ->
      sum_box_coordinates_wide(rest, acc + 100 * y1 + x1)
  }
}

fn modify_map(warehouse: Warehouse) -> WideWarehouse {
  let boxes =
    warehouse.boxes
    |> set.to_list
    |> list.map(fn(p) { #(#(2 * p.0, p.1), #(2 * p.0 + 1, p.1)) })
    |> set.from_list
  let walls =
    warehouse.walls
    |> set.to_list
    |> list.map(fn(p) { [#(2 * p.0, p.1), #(2 * p.0 + 1, p.1)] })
    |> list.flatten
    |> set.from_list
  let robot = #(warehouse.robot.0 * 2, warehouse.robot.1)

  WideWarehouse(robot, boxes, walls)
}

fn print_warehouse_line(wh: Warehouse, y: Int, x: Int, acc: String) -> String {
  let new = case
    set.contains(wh.boxes, #(x, y)),
    set.contains(wh.walls, #(x, y)),
    wh.robot == #(x, y)
  {
    True, False, False -> "O"
    False, True, False -> "#"
    False, False, True -> "@"
    False, False, False -> "."
    _, _, _ -> panic as "Overlapping objects"
  }

  case x {
    _ if x > 50 -> string.append(acc, new)
    _ -> print_warehouse_line(wh, y, x + 1, string.append(acc, new))
  }
}

fn print_warehouse(wh: Warehouse, y: Int, acc: String) -> String {
  case y {
    _ if y > 50 -> acc
    _ -> {
      let line = print_warehouse_line(wh, y, 0, "") <> "\n"
      print_warehouse(wh, y + 1, string.append(acc, line))
    }
  }
}

fn print_warehouse_line_wide(
  wh: WideWarehouse,
  y: Int,
  x: Int,
  acc: String,
) -> String {
  let new = case
    set.to_list(
      set.filter(wh.boxes, fn(b) {
        { b.0.0 == x && b.0.1 == y } || { b.1.0 == x && b.1.1 == y }
      }),
    ),
    set.contains(wh.walls, #(x, y)),
    wh.robot == #(x, y)
  {
    [box], False, False if box.0.0 == x -> "["
    [box], False, False if box.1.0 == x -> "]"
    [], True, False -> "#"
    [], False, True -> "@"
    [], False, False -> "."
    _, _, _ -> panic as "Overlapping objects"
  }

  case x {
    _ if x > 50 -> string.append(acc, new)
    _ -> print_warehouse_line_wide(wh, y, x + 1, string.append(acc, new))
  }
}

fn print_warehouse_wide(wh: WideWarehouse, y: Int, acc: String) -> String {
  case y {
    _ if y > 50 -> acc
    _ -> {
      let line = print_warehouse_line_wide(wh, y, 0, "") <> "\n"
      print_warehouse_wide(wh, y + 1, string.append(acc, line))
    }
  }
}
