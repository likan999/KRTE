package(default_visibility = ["//visibility:public"])

filegroup(
    name = "empty",
    srcs = [],
)

cc_toolchain_suite(
    name = "toolchain",
    toolchains = {
        "krte|gcc": ":cc-compiler-krte",
    },
)

cc_toolchain(
    name = "cc-compiler-krte",
    all_files = ":empty",
    compiler_files = ":empty",
    cpu = "krte",
    dwp_files = ":empty",
    dynamic_runtime_libs = [":empty"],
    linker_files = ":empty",
    objcopy_files = ":empty",
    static_runtime_libs = [":empty"],
    strip_files = ":empty",
    supports_param_files = 1,
)
