Build with:
`$  bazel build :actix-web-app`

deps:

`$ cargo install sea-orm-cli`

postgres:

`$ bazel build :postgres`
`$ bazel run :postgres`

Check if anything is on port:

`$ sudo lsof -i :5432`

kill if present

`$ sudo kill 5432`

ibazel:

ibazel monitors your source files and runs Bazel commands when changes are
detected. You can use it to rebuild your Rust project, run tests, or even
restart your Actix Web server when changes are made.

`$ git clone git@github.com:bazelbuild/bazel-watcher`
`$ cd bazel-watcher`
`$ bazel build //cmd/ibazel`
`$ export PATH=$PATH:$PWD/bazel-bin/cmd/ibazel/ibazel`

then 
`$ ibazel run :rust_image`
