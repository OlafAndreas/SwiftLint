load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_library",
)
load("@rules_cc//cc:cc_library.bzl", "cc_library")

cc_library(
    name = "SwiftSectionsShim",
    srcs = ["Sources/SwiftSectionsShim/Shim.c"],
    hdrs = ["Sources/SwiftSectionsShim/include/SwiftSectionsShim.h"],
    includes = ["Sources/SwiftSectionsShim/include"],
    tags = ["swift_module=SwiftSectionsShim"],
)

swift_library(
    name = "SwiftSections",
    srcs = glob(["Sources/SwiftSections/*.swift"]),
    module_name = "SwiftSections",
    visibility = ["//visibility:public"],
    deps = select({
        "@platforms//os:linux": [":SwiftSectionsShim"],
        "//conditions:default": [],
    }),
)
