const std = @import("std");
const lexer = @import("lexer.zig");

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

    const user_input = try ask_user(&buf);

    const tokens = try lexer.lex(user_input);

    std.debug.print("{any}\n", .{tokens.items});
}
