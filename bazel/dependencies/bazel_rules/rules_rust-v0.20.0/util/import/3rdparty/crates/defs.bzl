###############################################################################
# @generated
# DO NOT MODIFY: This file is auto-generated by a crate_universe tool. To
# regenerate this file, run the following:
#
#     bazel run @//util/import/3rdparty:crates_vendor
###############################################################################
"""
# `crates_repository` API

- [aliases](#aliases)
- [crate_deps](#crate_deps)
- [all_crate_deps](#all_crate_deps)
- [crate_repositories](#crate_repositories)

"""

load("@bazel_skylib//lib:selects.bzl", "selects")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

###############################################################################
# MACROS API
###############################################################################

# An identifier that represent common dependencies (unconditional).
_COMMON_CONDITION = ""

def _flatten_dependency_maps(all_dependency_maps):
    """Flatten a list of dependency maps into one dictionary.

    Dependency maps have the following structure:

    ```python
    DEPENDENCIES_MAP = {
        # The first key in the map is a Bazel package
        # name of the workspace this file is defined in.
        "workspace_member_package": {

            # Not all dependnecies are supported for all platforms.
            # the condition key is the condition required to be true
            # on the host platform.
            "condition": {

                # An alias to a crate target.     # The label of the crate target the
                # Aliases are only crate names.   # package name refers to.
                "package_name":                   "@full//:label",
            }
        }
    }
    ```

    Args:
        all_dependency_maps (list): A list of dicts as described above

    Returns:
        dict: A dictionary as described above
    """
    dependencies = {}

    for workspace_deps_map in all_dependency_maps:
        for pkg_name, conditional_deps_map in workspace_deps_map.items():
            if pkg_name not in dependencies:
                non_frozen_map = dict()
                for key, values in conditional_deps_map.items():
                    non_frozen_map.update({key: dict(values.items())})
                dependencies.setdefault(pkg_name, non_frozen_map)
                continue

            for condition, deps_map in conditional_deps_map.items():
                # If the condition has not been recorded, do so and continue
                if condition not in dependencies[pkg_name]:
                    dependencies[pkg_name].setdefault(condition, dict(deps_map.items()))
                    continue

                # Alert on any miss-matched dependencies
                inconsistent_entries = []
                for crate_name, crate_label in deps_map.items():
                    existing = dependencies[pkg_name][condition].get(crate_name)
                    if existing and existing != crate_label:
                        inconsistent_entries.append((crate_name, existing, crate_label))
                    dependencies[pkg_name][condition].update({crate_name: crate_label})

    return dependencies

def crate_deps(deps, package_name = None):
    """Finds the fully qualified label of the requested crates for the package where this macro is called.

    Args:
        deps (list): The desired list of crate targets.
        package_name (str, optional): The package name of the set of dependencies to look up.
            Defaults to `native.package_name()`.

    Returns:
        list: A list of labels to generated rust targets (str)
    """

    if not deps:
        return []

    if package_name == None:
        package_name = native.package_name()

    # Join both sets of dependencies
    dependencies = _flatten_dependency_maps([
        _NORMAL_DEPENDENCIES,
        _NORMAL_DEV_DEPENDENCIES,
        _PROC_MACRO_DEPENDENCIES,
        _PROC_MACRO_DEV_DEPENDENCIES,
        _BUILD_DEPENDENCIES,
        _BUILD_PROC_MACRO_DEPENDENCIES,
    ]).pop(package_name, {})

    # Combine all conditional packages so we can easily index over a flat list
    # TODO: Perhaps this should actually return select statements and maintain
    # the conditionals of the dependencies
    flat_deps = {}
    for deps_set in dependencies.values():
        for crate_name, crate_label in deps_set.items():
            flat_deps.update({crate_name: crate_label})

    missing_crates = []
    crate_targets = []
    for crate_target in deps:
        if crate_target not in flat_deps:
            missing_crates.append(crate_target)
        else:
            crate_targets.append(flat_deps[crate_target])

    if missing_crates:
        fail("Could not find crates `{}` among dependencies of `{}`. Available dependencies were `{}`".format(
            missing_crates,
            package_name,
            dependencies,
        ))

    return crate_targets

def all_crate_deps(
        normal = False,
        normal_dev = False,
        proc_macro = False,
        proc_macro_dev = False,
        build = False,
        build_proc_macro = False,
        package_name = None):
    """Finds the fully qualified label of all requested direct crate dependencies \
    for the package where this macro is called.

    If no parameters are set, all normal dependencies are returned. Setting any one flag will
    otherwise impact the contents of the returned list.

    Args:
        normal (bool, optional): If True, normal dependencies are included in the
            output list.
        normal_dev (bool, optional): If True, normal dev dependencies will be
            included in the output list..
        proc_macro (bool, optional): If True, proc_macro dependencies are included
            in the output list.
        proc_macro_dev (bool, optional): If True, dev proc_macro dependencies are
            included in the output list.
        build (bool, optional): If True, build dependencies are included
            in the output list.
        build_proc_macro (bool, optional): If True, build proc_macro dependencies are
            included in the output list.
        package_name (str, optional): The package name of the set of dependencies to look up.
            Defaults to `native.package_name()` when unset.

    Returns:
        list: A list of labels to generated rust targets (str)
    """

    if package_name == None:
        package_name = native.package_name()

    # Determine the relevant maps to use
    all_dependency_maps = []
    if normal:
        all_dependency_maps.append(_NORMAL_DEPENDENCIES)
    if normal_dev:
        all_dependency_maps.append(_NORMAL_DEV_DEPENDENCIES)
    if proc_macro:
        all_dependency_maps.append(_PROC_MACRO_DEPENDENCIES)
    if proc_macro_dev:
        all_dependency_maps.append(_PROC_MACRO_DEV_DEPENDENCIES)
    if build:
        all_dependency_maps.append(_BUILD_DEPENDENCIES)
    if build_proc_macro:
        all_dependency_maps.append(_BUILD_PROC_MACRO_DEPENDENCIES)

    # Default to always using normal dependencies
    if not all_dependency_maps:
        all_dependency_maps.append(_NORMAL_DEPENDENCIES)

    dependencies = _flatten_dependency_maps(all_dependency_maps).pop(package_name, None)

    if not dependencies:
        if dependencies == None:
            fail("Tried to get all_crate_deps for package " + package_name + " but that package had no Cargo.toml file")
        else:
            return []

    crate_deps = list(dependencies.pop(_COMMON_CONDITION, {}).values())
    for condition, deps in dependencies.items():
        crate_deps += selects.with_or({_CONDITIONS[condition]: deps.values()})

    return crate_deps

def aliases(
        normal = False,
        normal_dev = False,
        proc_macro = False,
        proc_macro_dev = False,
        build = False,
        build_proc_macro = False,
        package_name = None):
    """Produces a map of Crate alias names to their original label

    If no dependency kinds are specified, `normal` and `proc_macro` are used by default.
    Setting any one flag will otherwise determine the contents of the returned dict.

    Args:
        normal (bool, optional): If True, normal dependencies are included in the
            output list.
        normal_dev (bool, optional): If True, normal dev dependencies will be
            included in the output list..
        proc_macro (bool, optional): If True, proc_macro dependencies are included
            in the output list.
        proc_macro_dev (bool, optional): If True, dev proc_macro dependencies are
            included in the output list.
        build (bool, optional): If True, build dependencies are included
            in the output list.
        build_proc_macro (bool, optional): If True, build proc_macro dependencies are
            included in the output list.
        package_name (str, optional): The package name of the set of dependencies to look up.
            Defaults to `native.package_name()` when unset.

    Returns:
        dict: The aliases of all associated packages
    """
    if package_name == None:
        package_name = native.package_name()

    # Determine the relevant maps to use
    all_aliases_maps = []
    if normal:
        all_aliases_maps.append(_NORMAL_ALIASES)
    if normal_dev:
        all_aliases_maps.append(_NORMAL_DEV_ALIASES)
    if proc_macro:
        all_aliases_maps.append(_PROC_MACRO_ALIASES)
    if proc_macro_dev:
        all_aliases_maps.append(_PROC_MACRO_DEV_ALIASES)
    if build:
        all_aliases_maps.append(_BUILD_ALIASES)
    if build_proc_macro:
        all_aliases_maps.append(_BUILD_PROC_MACRO_ALIASES)

    # Default to always using normal aliases
    if not all_aliases_maps:
        all_aliases_maps.append(_NORMAL_ALIASES)
        all_aliases_maps.append(_PROC_MACRO_ALIASES)

    aliases = _flatten_dependency_maps(all_aliases_maps).pop(package_name, None)

    if not aliases:
        return dict()

    common_items = aliases.pop(_COMMON_CONDITION, {}).items()

    # If there are only common items in the dictionary, immediately return them
    if not len(aliases.keys()) == 1:
        return dict(common_items)

    # Build a single select statement where each conditional has accounted for the
    # common set of aliases.
    crate_aliases = {"//conditions:default": common_items}
    for condition, deps in aliases.items():
        condition_triples = _CONDITIONS[condition]
        if condition_triples in crate_aliases:
            crate_aliases[condition_triples].update(deps)
        else:
            crate_aliases.update({_CONDITIONS[condition]: dict(deps.items() + common_items)})

    return selects.with_or(crate_aliases)

###############################################################################
# WORKSPACE MEMBER DEPS AND ALIASES
###############################################################################

_NORMAL_DEPENDENCIES = {
    "": {
        _COMMON_CONDITION: {
            "aho-corasick": "@rules_rust_util_import__aho-corasick-0.7.15//:aho_corasick",
            "lazy_static": "@rules_rust_util_import__lazy_static-1.4.0//:lazy_static",
            "proc-macro2": "@rules_rust_util_import__proc-macro2-1.0.33//:proc_macro2",
            "quickcheck": "@rules_rust_util_import__quickcheck-1.0.3//:quickcheck",
            "quote": "@rules_rust_util_import__quote-1.0.10//:quote",
            "syn": "@rules_rust_util_import__syn-1.0.82//:syn",
        },
    },
}

_NORMAL_ALIASES = {
    "": {
        _COMMON_CONDITION: {
        },
    },
}

_NORMAL_DEV_DEPENDENCIES = {
    "": {
    },
}

_NORMAL_DEV_ALIASES = {
    "": {
    },
}

_PROC_MACRO_DEPENDENCIES = {
    "": {
    },
}

_PROC_MACRO_ALIASES = {
    "": {
    },
}

_PROC_MACRO_DEV_DEPENDENCIES = {
    "": {
    },
}

_PROC_MACRO_DEV_ALIASES = {
    "": {
    },
}

_BUILD_DEPENDENCIES = {
    "": {
    },
}

_BUILD_ALIASES = {
    "": {
    },
}

_BUILD_PROC_MACRO_DEPENDENCIES = {
    "": {
    },
}

_BUILD_PROC_MACRO_ALIASES = {
    "": {
    },
}

_CONDITIONS = {
    "cfg(target_os = \"wasi\")": ["wasm32-wasi"],
    "cfg(unix)": ["aarch64-apple-darwin", "aarch64-apple-ios", "aarch64-apple-ios-sim", "aarch64-linux-android", "aarch64-unknown-linux-gnu", "arm-unknown-linux-gnueabi", "armv7-linux-androideabi", "armv7-unknown-linux-gnueabi", "i686-apple-darwin", "i686-linux-android", "i686-unknown-freebsd", "i686-unknown-linux-gnu", "powerpc-unknown-linux-gnu", "s390x-unknown-linux-gnu", "x86_64-apple-darwin", "x86_64-apple-ios", "x86_64-linux-android", "x86_64-unknown-freebsd", "x86_64-unknown-linux-gnu"],
}

###############################################################################

def crate_repositories():
    """A macro for defining repositories for all generated crates"""
    maybe(
        http_archive,
        name = "rules_rust_util_import__aho-corasick-0.7.15",
        sha256 = "7404febffaa47dac81aa44dba71523c9d069b1bdc50a77db41195149e17f68e5",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/aho-corasick/0.7.15/download"],
        strip_prefix = "aho-corasick-0.7.15",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.aho-corasick-0.7.15.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__cfg-if-1.0.0",
        sha256 = "baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/cfg-if/1.0.0/download"],
        strip_prefix = "cfg-if-1.0.0",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.cfg-if-1.0.0.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__env_logger-0.8.4",
        sha256 = "a19187fea3ac7e84da7dacf48de0c45d63c6a76f9490dae389aead16c243fce3",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/env_logger/0.8.4/download"],
        strip_prefix = "env_logger-0.8.4",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.env_logger-0.8.4.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__getrandom-0.2.8",
        sha256 = "c05aeb6a22b8f62540c194aac980f2115af067bfe15a0734d7277a768d396b31",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/getrandom/0.2.8/download"],
        strip_prefix = "getrandom-0.2.8",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.getrandom-0.2.8.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__lazy_static-1.4.0",
        sha256 = "e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/lazy_static/1.4.0/download"],
        strip_prefix = "lazy_static-1.4.0",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.lazy_static-1.4.0.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__libc-0.2.139",
        sha256 = "201de327520df007757c1f0adce6e827fe8562fbc28bfd9c15571c66ca1f5f79",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/libc/0.2.139/download"],
        strip_prefix = "libc-0.2.139",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.libc-0.2.139.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__log-0.4.17",
        sha256 = "abb12e687cfb44aa40f41fc3978ef76448f9b6038cad6aef4259d3c095a2382e",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/log/0.4.17/download"],
        strip_prefix = "log-0.4.17",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.log-0.4.17.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__memchr-2.5.0",
        sha256 = "2dffe52ecf27772e601905b7522cb4ef790d2cc203488bbd0e2fe85fcb74566d",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/memchr/2.5.0/download"],
        strip_prefix = "memchr-2.5.0",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.memchr-2.5.0.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__proc-macro2-1.0.33",
        sha256 = "fb37d2df5df740e582f28f8560cf425f52bb267d872fe58358eadb554909f07a",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/proc-macro2/1.0.33/download"],
        strip_prefix = "proc-macro2-1.0.33",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.proc-macro2-1.0.33.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__quickcheck-1.0.3",
        sha256 = "588f6378e4dd99458b60ec275b4477add41ce4fa9f64dcba6f15adccb19b50d6",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/quickcheck/1.0.3/download"],
        strip_prefix = "quickcheck-1.0.3",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.quickcheck-1.0.3.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__quote-1.0.10",
        sha256 = "38bc8cc6a5f2e3655e0899c1b848643b2562f853f114bfec7be120678e3ace05",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/quote/1.0.10/download"],
        strip_prefix = "quote-1.0.10",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.quote-1.0.10.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__rand-0.8.5",
        sha256 = "34af8d1a0e25924bc5b7c43c079c942339d8f0a8b57c39049bef581b46327404",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/rand/0.8.5/download"],
        strip_prefix = "rand-0.8.5",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.rand-0.8.5.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__rand_core-0.6.4",
        sha256 = "ec0be4795e2f6a28069bec0b5ff3e2ac9bafc99e6a9a7dc3547996c5c816922c",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/rand_core/0.6.4/download"],
        strip_prefix = "rand_core-0.6.4",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.rand_core-0.6.4.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__regex-1.4.6",
        sha256 = "2a26af418b574bd56588335b3a3659a65725d4e636eb1016c2f9e3b38c7cc759",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/regex/1.4.6/download"],
        strip_prefix = "regex-1.4.6",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.regex-1.4.6.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__regex-syntax-0.6.28",
        sha256 = "456c603be3e8d448b072f410900c09faf164fbce2d480456f50eea6e25f9c848",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/regex-syntax/0.6.28/download"],
        strip_prefix = "regex-syntax-0.6.28",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.regex-syntax-0.6.28.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__syn-1.0.82",
        sha256 = "8daf5dd0bb60cbd4137b1b587d2fc0ae729bc07cf01cd70b36a1ed5ade3b9d59",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/syn/1.0.82/download"],
        strip_prefix = "syn-1.0.82",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.syn-1.0.82.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__unicode-xid-0.2.4",
        sha256 = "f962df74c8c05a667b5ee8bcf162993134c104e96440b663c8daa176dc772d8c",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/unicode-xid/0.2.4/download"],
        strip_prefix = "unicode-xid-0.2.4",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.unicode-xid-0.2.4.bazel"),
    )

    maybe(
        http_archive,
        name = "rules_rust_util_import__wasi-0.11.0-wasi-snapshot-preview1",
        sha256 = "9c8d87e72b64a3b4db28d11ce29237c246188f4f51057d65a7eab63b7987e423",
        type = "tar.gz",
        urls = ["https://crates.io/api/v1/crates/wasi/0.11.0+wasi-snapshot-preview1/download"],
        strip_prefix = "wasi-0.11.0+wasi-snapshot-preview1",
        build_file = Label("@rules_rust//util/import/3rdparty/crates:BUILD.wasi-0.11.0+wasi-snapshot-preview1.bazel"),
    )
