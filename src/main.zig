const std = @import("std");
const lexer = @import("quixil/lexer.zig");

fn ask_user(buf: []u8) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    _ = try stdout.print("\nProvide your input: ", .{});

    const input = (try stdin.readUntilDelimiterOrEof(buf, '\n')) orelse {
        return error.Null;
    };

    return input;
}

pub fn main() !void {
    var buf: [1024]u8 = undefined;

    var user_input = try ask_user(&buf);

    _ = try lexer.lextest(&user_input);

    //std.debug.print("This is your input: {s}\n", .{user_input});
}
