const std = @import("std");
const stdout = std.io.getStdOut().writer();
const Writer = std.io.Writer;
const Dir = std.fs.Dir;
const MAX_PATH_BYTES = std.fs.MAX_PATH_BYTES;
const AccessError = std.os.AccessError;

const Findup = struct { program: []u8, target: []u8, cwd: Dir };

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const findup = try getFindup(&arena.allocator);

    try stdout.print("program: {s}\n", .{findup.program});
    try stdout.print("target: {s}\n", .{findup.target});

    var cwd = findup.cwd;
    try printDir(cwd);
    //try std.os.chdir("..");

    inline for (.{ "build.zig", "nonexist" }) |f| {
        try stdout.print("file: {s}\n", .{f});
        if (try fileExists(cwd, f)) {
            try stdout.print("exists!\n", .{});
        } else {
            try stdout.print("doesn't exist!\n", .{});
        }
    }
}

fn getFindup(allocator: *std.mem.Allocator) anyerror!Findup {
    var args = std.process.args();
    const program = try args.next(allocator).?;
    //try stdout.print("program: {s}\n", .{program});
    const target = try args.next(allocator).?;
    //try stdout.print("target: {s}\n", .{target});
    const cwd = std.fs.cwd();

    return Findup{
        .program = program,
        .target = target,
        .cwd = cwd,
    };
}

fn printDir(dir: Dir) anyerror!void {
    var buffer: [MAX_PATH_BYTES]u8 = undefined;
    const dir_str = try dir.realpath(".", &buffer);
    try stdout.print("{s}\n", .{dir_str});
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
