const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const strip_debugging = b.option(bool, "strip", "strip debugging symbols") orelse false;

    const lib_term = b.addStaticLibrary(.{
        .name = "terminal",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/cTermio.zig"),
        .target = target,
        .optimize = optimize,
        .strip = strip_debugging,
    });

    _ = b.addModule("tui", .{
        .root_source_file = b.path("src/tui.zig"),
        .target = target,
        .optimize = optimize,
        .strip = strip_debugging,
    });

    const module_clevel = b.addModule("clevel", .{
        .root_source_file = b.path("src/cTermio.zig"),
        .target = target,
        .optimize = optimize,
        .strip = strip_debugging,
    });

    const obj_tui = b.addObject(.{
        .name = "tui",
        .root_source_file = b.path("src/tui.zig"),
        .target = target,
        .optimize = optimize,
    });

    const install_docs = b.addInstallDirectory(.{
        .source_dir = obj_tui.getEmittedDocs(),
        .install_dir = .{
            .custom = "..",
        },
        // .install_dir = .prefix,
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Generate documentation");
    docs_step.dependOn(&install_docs.step);

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    module_clevel.linkLibC();
    lib_term.linkLibC();
    b.installArtifact(lib_term);

    // const exe = b.addExecutable(.{
    //     .name = "simple-text-ui-for-zig",
    //     .root_source_file = b.path("src/main.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    if (b.option(bool, "examples", "install examples") orelse false) {
        // const example_files: [1][]const u8 = .{"src/ex_read_input_from_term.zig"};
        // const example_files: [2][]const u8 = .{ "src/ex_read_input_from_term.zig", "src/ex_multi_threaded.zig" };
        const example_files: [3][]const u8 = .{ "src/ex_read_input_from_term.zig", "src/ex_multi_threaded.zig", "src/ex_panels.zig" };
        const example_names: [3][]const u8 = .{ "simple_text_input", "simple_multi_threaded", "panels_frames" };
        for (example_files, example_names, 0..) |ex, name, index| {
            var ex_buffer: [512]u8 = undefined;
            const ex_name = try std.fmt.bufPrint(&ex_buffer, "{}_example_{s}", .{ index, name });
            const examples = b.addExecutable(.{
                .name = ex_name,
                .root_source_file = b.path(ex),
                .target = target,
                .optimize = optimize,
                .strip = strip_debugging,
            });
            examples.linkLibrary(lib_term);
            // examples.linkLibC();
            b.installArtifact(examples);
        }
    }

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    // const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    // run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // const exe_unit_tests = b.addTest(.{
    //     .root_source_file = b.path("src/main.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    // test_step.dependOn(&run_exe_unit_tests.step);
}
