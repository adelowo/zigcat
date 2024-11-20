const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer gpa.deinit();

    const allocator = gpa.allocator();

    if (std.os.argv.len != 2) {
        std.debug.print("you can only have one positional argument which is the file path\n", .{});
        std.process.exit(128);
    }

    const values = readFileLines(allocator, "build.zig");

    std.debug.print("{s} \n", values);

    allocator.free(values);
}

fn readFileLines(gpa: std.mem.Allocator, path: []const u8) ![]const []const u8 {
    const allocator = gpa.allocator();

    const file = std.fs.cwd().readFile(path, .{}) catch |err| {
        std.log.err("could not read file.. {s}\n", .{@errorName(err)});
        return;
    };

    defer file.close();

    // Read the file content into a buffer
    const file_content = try file.readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_content);

    // Split the content into lines
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var tokenizer = std.mem.tokenize(file_content, "\n");
    while (tokenizer.next()) |line| {
        try lines.append(line);
    }

    return lines.toOwnedSlice();
}
