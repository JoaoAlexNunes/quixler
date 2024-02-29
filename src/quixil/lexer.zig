const std = @import("std");
const ArrayList = std.ArrayList;

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

pub fn lex(source: *[]u8) !ArrayList(Token) {
    const tokens = ArrayList(Token);

    var i: usize = 0;
    while (i < source.len) : (i += 1) {
        const current = source[i];
        switch (current) {
            // Digits
            '0'...'9' => {
                var j = i;
                while (j < source.len and source[j] >= '0' and source[j] <= '9') : (j += 1) {}
                tokens.append(Token{ .kind = TokenKind.Atomic, .value = source[i..j] });
                i = j - 1; // Move the index to the end of the number
            },

            // Operators
            '+' => tokens.append(Token{ .kind = TokenKind.Add, .value = "+" }),
            '-' => tokens.append(Token{ .kind = TokenKind.Sub, .value = "-" }),
            '*' => tokens.append(Token{ .kind = TokenKind.Mul, .value = "*" }),
            '/' => tokens.append(Token{ .kind = TokenKind.Div, .value = "/" }),

            // Whitespace
            ' ' => continue,

            // End of File
            else => return tokens.append(Token{ .kind = TokenKind.EOF, .value = &[]u8{0} }), // Return EOF
        }
    }

    tokens.append(Token{ .kind = TokenKind.EOF, .value = &[]u8{0} });
    return tokens;
}

pub fn lextest(input: *[]u8) !void {
    const tokens = try lex(input);

    // Print out the tokens

    std.debug.print("{any}:\n", tokens.items);
}
