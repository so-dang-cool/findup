const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
const Writer = std.io.Writer;
const Dir = std.fs.Dir;
const MAX_PATH_BYTES = std.fs.MAX_PATH_BYTES;
const AccessError = std.posix.AccessError;

const Findup = struct { program: [:0]const u8, target: [:0]const u8, cwd: Dir, printHelp: bool, printVersion: bool };
const FindupError = error{NoFileSpecified};

const VERSION = "findup 1.1.2\n";

const USAGE =
    \\USAGE:
    \\    findup FILE
    \\
    \\FLAGS:
    \\    -h, --help    Prints help information
    \\    -V, --version Prints version information
    \\
    \\Finds a directory containing FILE. Tested by filename with exact string equality. Starts searching at the current working directory and recurses "up" through parent directories.
    \\
    \\The first directory containing FILE will be printed. If no directory contains FILE, nothing is printed and the program exits with an exit code of 1.
    \\
    \\By J.R. Hill. https://github.com/booniepepper/findup
    \\
;

pub fn main() anyerror!void {
    var buf: [MAX_PATH_BYTES]u8 = undefined;

    const findup = initFindup() catch |err| {
        try stderr.print("ERROR: {?}\n\n{s}", .{ err, USAGE });
        std.process.exit(1);
    };

    if (findup.printHelp) {
        try stdout.print("{s}\n{s}", .{ VERSION, USAGE });
        std.process.exit(0);
    } else if (findup.printVersion) {
        try stdout.print(VERSION, .{});
        std.process.exit(0);
    }

    var cwd = findup.cwd;

    const result = while (true) {
        const cwdStr = try dirStr(cwd, buf[0..]);
        if (try fileExists(cwd, findup.target)) break cwdStr;
        if (std.mem.eql(u8, "/", cwdStr)) break null;
        try std.posix.chdir("..");
        cwd = std.fs.cwd();
    } else unreachable;

    if (result == null) std.process.exit(1);

    try stdout.print("{s}\n", .{result.?});
}

fn initFindup() anyerror!Findup {
    var args = std.process.args();

    const program = args.next().?;
    const maybeTarget = args.next();
    const target = if (maybeTarget == null) return FindupError.NoFileSpecified else maybeTarget.?;
    const cwd = std.fs.cwd();

    const printHelp = std.mem.eql(u8, "-h", target) or std.mem.eql(u8, "--help", target);
    const printVersion = std.mem.eql(u8, "-V", target) or std.mem.eql(u8, "--version", target);

    return Findup{ .program = program, .target = target, .cwd = cwd, .printHelp = printHelp, .printVersion = printVersion };
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
