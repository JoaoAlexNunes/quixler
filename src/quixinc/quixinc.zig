const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const ast = @import("ast.zig");

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

    var tokens = try lexer.lex(user_input);

    const parsed_ast = try parser.parse(try tokens.toOwnedSlice());

    std.debug.print("Ast:{any}\n", .{parsed_ast});

    const ast_evaled = ast.eval(&parsed_ast);

    std.debug.print("Result is: {d:.2}\n", .{ast_evaled});
}
