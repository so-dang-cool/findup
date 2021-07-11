const std = @import("std");
const log = std.log;
const Dir = std.fs.Dir;
const AccessError = std.os.AccessError;

pub fn main() anyerror!void {
    const cwd = std.fs.cwd();
    log.info("CWD: {s}", .{cwd});

    //try std.os.chdir("..");

    inline for (.{ "build.zig", "nonexit.zig" }) |f| {
        log.info("file: {s}", .{f});
        if (try fileExists(cwd, f)) {
            log.info("exists!", .{});
        } else {
            log.info("doesn't exist!", .{});
        }
    }
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
