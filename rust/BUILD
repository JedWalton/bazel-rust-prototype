load("@rules_rust//rust:defs.bzl", "rust_binary")
load("@io_bazel_rules_docker//rust:image.bzl", "rust_image")

package(default_visibility = ["//visibility:public"])

rust_binary(
    name = "actix-web-app",
    srcs = ["src/main.rs"],
    edition = "2021",
)


rust_image(
    name = "rust_image",
    srcs = ["src/main.rs"],
    edition = "2021",
    deps = [
        "@actix_web_crate_index//:actix-web",
        "@actix_web_crate_index//:futures",
        "@actix_web_crate_index//:sea-orm",
    ],
)

load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_bundle")

container_bundle(
    name = "rust_image_bundle",
    images = {
        "rust_image": ":rust_image",
    },
)
