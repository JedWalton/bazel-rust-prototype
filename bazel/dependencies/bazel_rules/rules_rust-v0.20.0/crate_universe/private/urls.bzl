"""A file containing urls and associated sha256 values for cargo-bazel binaries

This file is auto-generated for each release to match the urls and sha256s of
the binaries produced for it.
"""

# Example:
# {
#     "x86_64-unknown-linux-gnu": "https://domain.com/downloads/cargo-bazel-x86_64-unknown-linux-gnu",
#     "x86_64-apple-darwin": "https://domain.com/downloads/cargo-bazel-x86_64-apple-darwin",
#     "x86_64-pc-windows-msvc": "https://domain.com/downloads/cargo-bazel-x86_64-pc-windows-msvc",
# }
CARGO_BAZEL_URLS = {
  "aarch64-apple-darwin": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-aarch64-apple-darwin",
  "aarch64-pc-windows-msvc": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-aarch64-pc-windows-msvc.exe",
  "aarch64-unknown-linux-gnu": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-aarch64-unknown-linux-gnu",
  "x86_64-apple-darwin": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-x86_64-apple-darwin",
  "x86_64-pc-windows-gnu": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-x86_64-pc-windows-gnu.exe",
  "x86_64-pc-windows-msvc": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-x86_64-pc-windows-msvc.exe",
  "x86_64-unknown-linux-gnu": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-x86_64-unknown-linux-gnu",
  "x86_64-unknown-linux-musl": "https://github.com/bazelbuild/rules_rust/releases/download/0.20.0/cargo-bazel-x86_64-unknown-linux-musl"
}

# Example:
# {
#     "x86_64-unknown-linux-gnu": "1d687fcc860dc8a1aa6198e531f0aee0637ed506d6a412fe2b9884ff5b2b17c0",
#     "x86_64-apple-darwin": "0363e450125002f581d29cf632cc876225d738cfa433afa85ca557afb671eafa",
#     "x86_64-pc-windows-msvc": "f5647261d989f63dafb2c3cb8e131b225338a790386c06cf7112e43dd9805882",
# }
CARGO_BAZEL_SHA256S = {
  "aarch64-apple-darwin": "052424953a71d42d61361754d1f63b319c5b97ca33347aacac7ce5faeeb4a2f5",
  "aarch64-pc-windows-msvc": "84ca394ae55af729f22778ed0b1aa544e2f8bcc8aa00623f5700895e3740e80d",
  "aarch64-unknown-linux-gnu": "a266de5b9056662d5738e37ff874ddc0514132dc0d0aff4d7b27e117070d8181",
  "x86_64-apple-darwin": "d84a50df79ad4ecf6135a6faa3d29c98896c621698f2674cdd47eeeb11457535",
  "x86_64-pc-windows-gnu": "69746f3c842ba1aa96db02a70bf165a212763490ac92a4eabbb7d4ebc3248a13",
  "x86_64-pc-windows-msvc": "efa769a66897c60d689885be8cee3eead1ecede10485d58eee8ddaa63d04c8f4",
  "x86_64-unknown-linux-gnu": "921c6ace3903bf88018f30fe0880de040cf68f1a240566b5be591b4e22e4ba22",
  "x86_64-unknown-linux-musl": "87e90f359b5f2b60ac897ffd75277cc338a158f2c3f3625fa00548f3f1620db1"
}

# Example:
# Label("//crate_universe:cargo_bazel_bin")
CARGO_BAZEL_LABEL = Label("//crate_universe:cargo_bazel_bin")
