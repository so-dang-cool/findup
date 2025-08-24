const std = @import("std");
const testing = std.testing;
const allocator = testing.allocator;

const findup = "./zig-out/bin/findup";

test "findup --version" {
    const invocation = &[_][]const u8{ findup, "--version" };

    const result = try std.process.Child.run(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqualStrings("findup 2.0.0\n", result.stdout);
}

test "findup build.zig" {
    const invocation = &[_][]const u8{ findup, "build.zig" };

    const result = try std.process.Child.run(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    var buf: [256]u8 = undefined;
    const cwd = try std.posix.getcwd(&buf);

    const expectedStdout = try std.mem.concat(allocator, u8, &[_][]const u8{ cwd, &[_]u8{std.fs.path.sep}, "build.zig", "\n" });
    defer allocator.free(expectedStdout);
    try testing.expectEqualStrings(expectedStdout, result.stdout);
    try testing.expectEqualStrings("", result.stderr);
}

test "findup -d build.zig" {
    const invocation = &[_][]const u8{ findup, "-d", "build.zig" };

    const result = try std.process.Child.run(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    var buf: [256]u8 = undefined;
    const cwd = try std.posix.getcwd(&buf);

    const expectedStdout = try std.mem.join(allocator, "", &[_][]const u8{ cwd, "\n" });
    defer allocator.free(expectedStdout);
    try testing.expectEqualStrings(expectedStdout, result.stdout);
    try testing.expectEqualStrings("", result.stderr);
}

test "findup SOME_FILE_THAT_I_SUPPOSE_DOES_NOT_EXIST" {
    const invocation = &[_][]const u8{ findup, "SOME_FILE_THAT_I_SUPPOSE_DOES_NOT_EXIST" };

    const result = try std.process.Child.run(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqual(std.process.Child.Term{ .Exited = 1 }, result.term);
    try testing.expectEqualStrings("", result.stdout);
    try testing.expectEqualStrings("", result.stderr);
}
