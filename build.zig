const std = @import("std");

pub fn build(b: *std.build.Builder) void {

    // ----- install ------
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("findup", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    // ----- run -----

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // ----- test -----

    const test_cmd = b.addTest("src/test.zig");
    test_cmd.step.dependOn(b.getInstallStep());
    const test_step = b.step("test", "Run test against the built CLI");
    test_step.dependOn(&test_cmd.step);
}
