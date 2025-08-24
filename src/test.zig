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

    // Test that some non-empty string is returned.
    try testing.expectStringStartsWith(result.stdout, cwd);
    try testing.expectStringEndsWith(result.stdout, "build.zig\n");

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
