const std = @import("std");
const testing = std.testing;
const allocator = testing.allocator;

const ChildProcess = std.ChildProcess;

const findup = "./zig-out/bin/findup";

test "findup --version" {
    const invocation = &[_][]const u8{ findup, "--version" };

    const result = try ChildProcess.exec(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    try testing.expectEqualStrings("findup 1.1.1\n", result.stdout);
}

test "findup build.zig" {
    const invocation = &[_][]const u8{ findup, "build.zig" };

    const result = try ChildProcess.exec(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    // Test that some non-empty string is returned.
    const zero: usize = 0;
    const is_equal = testing.expectEqual(zero, result.stdout.len);
    try testing.expectError(error.TestExpectedEqual, is_equal);
}

test "findup SOME_FILE_THAT_I_SUPPOSE_DOES_NOT_EXIST" {
    const invocation = &[_][]const u8{ findup, "SOME_FILE_THAT_I_SUPPOSE_DOES_NOT_EXIST" };

    const result = try ChildProcess.exec(.{ .allocator = allocator, .argv = invocation });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    const zero: usize = 0;
    try testing.expectEqual(ChildProcess.Term{ .Exited = 1 }, result.term);
    try testing.expectEqual(zero, result.stdout.len);
    try testing.expectEqual(zero, result.stderr.len);
}
