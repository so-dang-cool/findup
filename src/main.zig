const std = @import("std");

var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

var stderr_buffer: [1024]u8 = undefined;
var stderr_writer = std.fs.File.stderr().writer(&stderr_buffer);
const stderr = &stderr_writer.interface;

const Findup = struct {
    program: [:0]const u8,
    target: ?[:0]const u8,
    cwd: std.fs.Dir,
    printDirOnly: bool,
    printHelp: bool,
    printVersion: bool,
};

const VERSION = "findup 2.0.0";

const USAGE =
    \\USAGE:
    \\    findup [FLAG] FILE
    \\
    \\FLAGS:
    \\    -d, --print-directory Print the parent directory
    \\    -h, --help            Print this help message
    \\    -V, --version         Print version
    \\
    \\Finds the FILE. Tested by filename with exact string equality. Starts searching at the current working directory and recurses "up" through parent directories.
    \\
    \\The nearest FILE will be printed. If no parent directory contains FILE, nothing is printed and the program exits with an exit code of 1.
    \\
    \\If --print-directory (-d) is specified, only the parent directory will be printed, omitting the filename.
    \\
    \\https://github.com/so-dang-cool/findup
    \\
;

pub fn main() anyerror!void {
    var dir_buf: [std.fs.max_path_bytes]u8 = undefined;

    const findup = initFindup();

    if (findup.printHelp) {
        try stdout.print("{s}\n{s}", .{ VERSION, USAGE });
        try stdout.flush();
        std.posix.exit(0);
    } else if (findup.printVersion) {
        try stdout.print("{s}\n", .{VERSION});
        try stdout.flush();
        std.posix.exit(0);
    }

    if (findup.target == null) {
        try stderr.print("ERROR: No FILE specified\n\n{s}", .{USAGE});
        try stderr.flush();
        std.posix.exit(2);
    }

    const file = findup.target.?;

    var cwd = findup.cwd;
    const result = while (true) {
        const cwdStr = try cwd.realpath(".", dir_buf[0..]);
        if (try fileExists(cwd, file)) break cwdStr;
        if (std.mem.eql(u8, "/", cwdStr)) break null;
        try std.posix.chdir("..");
        cwd = std.fs.cwd();
    } else unreachable;

    // Nothing found
    if (result == null) std.posix.exit(1);

    // Found!
    try stdout.print("{s}", .{result.?});
    if (!findup.printDirOnly) try stdout.print("{c}{s}", .{ std.fs.path.sep, file });
    try stdout.print("\n", .{});
    try stdout.flush();
}

fn initFindup() Findup {
    var args = std.process.args();

    const program = args.next().?;
    const cwd = std.fs.cwd();

    var printDirOnly = false;
    var printHelp = false;
    var printVersion = false;

    var target: ?[:0]const u8 = null;

    while (args.next()) |arg| {
        if (flagged(arg, "-d", "--print-directory"))
            printDirOnly = true
        else if (flagged(arg, "-h", "--help"))
            printHelp = true
        else if (flagged(arg, "-V", "--version"))
            printVersion = true
        else if (target == null)
            target = arg;
    }

    return Findup{
        .program = program,
        .target = target,
        .cwd = cwd,
        .printDirOnly = printDirOnly,
        .printHelp = printHelp,
        .printVersion = printVersion,
    };
}

fn flagged(arg: []const u8, short: []const u8, long: []const u8) bool {
    return std.mem.eql(u8, short, arg) or std.mem.eql(u8, long, arg);
}

fn fileExists(dir: std.fs.Dir, filename: []const u8) !bool {
    dir.access(filename, .{}) catch |err| {
        return switch (err) {
            error.FileNotFound => false,
            else => err,
        };
    };
    return true;
}
