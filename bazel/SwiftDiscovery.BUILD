load(
    "@build_bazel_rules_swift//swift:swift.bzl",
    "swift_compiler_plugin",
    "swift_library",
)

swift_library(
    name = "SwiftDiscoveryCore",
    srcs = glob(["Sources/SwiftDiscoveryCore/*.swift"]),
    module_name = "SwiftDiscoveryCore",
    visibility = ["//visibility:public"],
    deps = ["@SwiftSections"],
)

swift_library(
    name = "SwiftDiscoveryMacroSupport",
    srcs = glob(["Sources/SwiftDiscoveryMacroSupport/*.swift"]),
    module_name = "SwiftDiscoveryMacroSupport",
    visibility = ["//visibility:public"],
    deps = [
        "@SwiftSyntax//:SwiftDiagnostics_opt",
        "@SwiftSyntax//:SwiftSyntaxMacros_opt",
        "@SwiftSyntax//:SwiftSyntax_opt",
    ],
)

swift_compiler_plugin(
    name = "SwiftDiscoveryMacros",
    srcs = glob(["Sources/SwiftDiscoveryMacros/*.swift"]),
    module_name = "SwiftDiscoveryMacros",
    visibility = ["//visibility:public"],
    deps = [
        ":SwiftDiscoveryMacroSupport",
        "@SwiftSyntax//:SwiftCompilerPlugin_opt",
        "@SwiftSyntax//:SwiftSyntaxMacros_opt",
    ],
)

swift_library(
    name = "SwiftDiscovery",
    srcs = glob(["Sources/SwiftDiscovery/*.swift"]),
    module_name = "SwiftDiscovery",
    visibility = ["//visibility:public"],
    deps = [":SwiftDiscoveryCore"],
)
