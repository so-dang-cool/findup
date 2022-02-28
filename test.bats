#!/usr/bin/env bats

findup=./zig-out/bin/findup

@test "'findup --version' prints a version" {
  result="$($findup --version)"
  [ "$result" = "findup 1.1-rc" ]
}

@test "'findup home' finds some path" {
  result="$($findup home)"
  [ -n "$result" ]
}

dir=SOME_DIRECTORY_THAT_I_HOPE_DOES_NOT_EXIST
@test "'findup $dir' finds nothing and nonzero exit code" {
  result="$(not $findup $dir)"
  [ -z "$result" ]
}

