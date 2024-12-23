const std = @import("std");
const testing = std.testing;
const allocator = testing.allocator;

const ChildProcess = std.process.Child;

const findup = "./zig-out/bin/findup";

test "findup --version" {
    const invocation = &[_][]const u8{ findup, "--version" };
    const result = try ChildProcess.run(.{ .argv = invocation, .allocator = allocator });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqualStrings("findup 1.1.2\n", result.stdout);
}

test "findup build.zig" {
    const invocation = &[_][]const u8{ findup, "build.zig" };

    const result = try ChildProcess.run(.{ .argv = invocation, .allocator = allocator });

    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    var buf: [256]u8 = undefined;
    const cwd = try std.posix.getcwd(&buf);

    // Test that some non-empty string is returned.
    try testing.expectStringStartsWith(std.mem.trimRight(u8, cwd, &std.ascii.whitespace), std.mem.trimRight(u8, result.stdout, &std.ascii.whitespace));
    try testing.expectEqualStrings("", result.stderr);
}

test "findup SOME_FILE_THAT_I_SUPPOSE_DOES_NOT_EXIST" {
    const invocation = &[_][]const u8{ findup, "SOME_FILE_THAT_I_SUPPOSE_DOES_NOT_EXIST" };

    const result = try ChildProcess.run(.{ .argv = invocation, .allocator = allocator });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqual(ChildProcess.Term{ .Exited = 1 }, result.term);
    try testing.expectEqualStrings("", result.stdout);
    try testing.expectEqualStrings("", result.stderr);
}
