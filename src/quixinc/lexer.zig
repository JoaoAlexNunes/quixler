const std = @import("std");
const ArrayList = std.ArrayList;

var buffer: [1000]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

pub const TokenKind = enum {
    Atomic,
    Sub,
    Add,
    Mul,
    Div,
    EOF,
};

pub const Token = struct {
    kind: TokenKind,
    value: []u8,
};

pub fn lex(source: []u8) !ArrayList(Token) {
    var tokens = ArrayList(Token).init(allocator);

    var start: usize = 0;
    while (start < source.len) {
        const current = source[start];

        switch (current) {
            // Digits
            '0'...'9' => {
                const i = start;
                while (start < source.len and source[start] >= '0' and source[start] <= '9') : (start += 1) {}
                try tokens.append(Token{ .kind = TokenKind.Atomic, .value = source[i..start] });
            },

            // Operators
            '+' => {
                try tokens.append(Token{ .kind = TokenKind.Add, .value = source[start .. start + 1] });
                start += 1;
            },
            '-' => {
                try tokens.append(Token{ .kind = TokenKind.Sub, .value = source[start .. start + 1] });
                start += 1;
            },
            '*' => {
                try tokens.append(Token{ .kind = TokenKind.Mul, .value = source[start .. start + 1] });
                start += 1;
            },
            '/' => {
                try tokens.append(Token{ .kind = TokenKind.Div, .value = source[start .. start + 1] });
                start += 1;
            },

            // Whitespace
            ' ' => start += 1,

            // End of File
            else => {
                return error.InvalidChar;
            },
        }
    }

    try tokens.append(Token{ .kind = TokenKind.EOF, .value = source[0..1] });
    return tokens;
}

pub fn lextest(input: []u8) !void {
    const tokens = try lex(input);

    // Print out the tokens
    std.debug.print("{any}\n", .{tokens.items});
}
