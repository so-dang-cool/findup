const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
const Writer = std.io.Writer;
const Dir = std.fs.Dir;
const MAX_PATH_BYTES = std.fs.MAX_PATH_BYTES;
const AccessError = std.os.AccessError;

// TODO: Add --help and --verbose flags

const Findup = struct { program: []u8, target: ?[]u8, cwd: Dir };
const FindupError = error{NoFileSpecified};

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var buf: [MAX_PATH_BYTES]u8 = undefined;

    const findup = initFindup(&arena.allocator) catch |err| {
        try stderr.print("ERROR: {e}\n", .{err});
        try stderr.print("Usage: findup FILE\n", .{});
        std.os.exit(1);
    };

    const target = findup.target.?;
    var cwd = findup.cwd;

    const result = while (true) {
        var cwdStr = try dirStr(cwd, buf[0..]);
        if (try fileExists(cwd, target)) break cwdStr;
        if (std.mem.eql(u8, "/", cwdStr)) break null;
        try std.os.chdir("..");
        cwd = std.fs.cwd();
    } else unreachable;

    if (result == null) std.os.exit(1);

    try stdout.print("{s}\n", .{result.?});
}

fn initFindup(allocator: *std.mem.Allocator) anyerror!Findup {
    var args = std.process.args();

    const program = try args.next(allocator).?;
    const maybeTarget = args.next(allocator);
    const target = if (maybeTarget == null) return FindupError.NoFileSpecified else try maybeTarget.?;
    const cwd = std.fs.cwd();

    return Findup{
        .program = program,
        .target = target,
        .cwd = cwd,
    };
}

fn dirStr(dir: Dir, buf: []u8) anyerror![]u8 {
    return try dir.realpath(".", buf);
}

fn fileExists(dir: Dir, filename: []const u8) AccessError!bool {
    dir.access(filename, .{}) catch |err| {
        return switch (err) {
            AccessError.FileNotFound => false,
            else => err,
        };
    };
    return true;
}
