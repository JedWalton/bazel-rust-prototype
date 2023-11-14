load("@rules_rust//rust:defs.bzl", "rust_binary")
load("@io_bazel_rules_docker//rust:image.bzl", "rust_image")

package(default_visibility = ["//visibility:public"])

rust_binary(
    name = "actix-web-app",
    srcs = ["src/main.rs"],
    edition = "2021",
    deps = [
        "@actix_web_crate_index//:actix-web",
    ],
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


load("@io_bazel_rules_docker//container:container.bzl", "container_image")
container_image(
    name = "postgres",
    base = "@postgres//image", # This will pull the official PostgreSQL image from Docker Hub
    env = {
        "POSTGRES_USER": "postgres",
        "POSTGRES_PASSWORD": "mysecretpassword",
        "POSTGRES_DB": "mydatabase",
    },
    ports = [
        "5432",
    ],
)
