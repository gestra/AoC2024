import argv
import day01_test
import gleam/io

pub fn main() {
  case argv.load().arguments {
    ["1"] | ["01"] -> day01_test.main()
    _ -> io.println("usage: gleam test <number>")
  }
}
