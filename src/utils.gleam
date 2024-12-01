import gleam/string
import simplifile.{read}

pub fn read_input_file(file_path: String) -> List(String) {
  case read(file_path) {
    Ok(f) ->
      f
      |> string.trim()
      |> string.split("\n")
    _ -> panic as "Could not read input file"
  }
}
