const std = @import("std");
const ast = @import("ast.zig");
const lex = @import("lexer.zig");
const ArrayList = std.ArrayList;

const Expr = ast.Expr;
const OperatorKind = ast.OperatorKind;

const Token = lex.Token;
const TokenKind = lex.TokenKind;

const Bpvalue = struct { lvalue: u8, rvalue: u8 };
const heap_alloc = std.heap.page_allocator;

const Error = error{ OutOfMemory, InvalidChar };

fn prefix_bp(kind: TokenKind) u8 {
    return switch (kind) {
        TokenKind.Sub => 5,
        else => unreachable,
    };
}

fn infix_bp(kind: TokenKind) Bpvalue {
    return switch (kind) {
        TokenKind.Add, TokenKind.Sub => Bpvalue{ .lvalue = 1, .rvalue = 2 },
        TokenKind.Mul, TokenKind.Div => Bpvalue{ .lvalue = 3, .rvalue = 4 },
        else => unreachable,
    };
}

fn parse_operator(tokens: []Token, cursor: *usize) OperatorKind {
    const token = tokens[cursor.*];
    defer cursor.* += 1;
    return switch (token.kind) {
        TokenKind.Add => OperatorKind.add,
        TokenKind.Sub => OperatorKind.sub,
        TokenKind.Mul => OperatorKind.mul,
        TokenKind.Div => OperatorKind.div,
        else => unreachable,
    };
}

fn parse_primary(tokens: []Token, cursor: *usize) Error!Expr {
    const token = tokens[cursor.*];
    return try switch (token.kind) {
        TokenKind.Atomic => {
            cursor.* += 1;
            const temp = std.fmt.parseFloat(f64, token.value) catch {
                return Error.InvalidChar;
            };
            return Expr{ .atomic = temp };
        },
        else => unreachable,
    };
}

fn parse_expr_helper(tokens: []Token, cursor: *usize) Error!Expr {
    return switch (tokens[cursor.*].kind) {
        TokenKind.Atomic => parse_primary(tokens, cursor),
        TokenKind.Sub => {
            const p_bp = prefix_bp(TokenKind.Sub);
            const kind = parse_operator(tokens, cursor);
            const ptr = heap_alloc.create(Expr) catch {
                return Error.OutOfMemory;
            };
            ptr.* = try parse_helper(tokens, cursor, p_bp);

            const temp = ast.UnaryExpr{ .op = kind, .expr = ptr };
            return Expr{ .unary = temp };
        },
        else => unreachable,
    };
}

fn parse_helper(tokens: []Token, cursor: *usize, min_bp: u8) Error!Expr {
    // 3 + 4
    // ^
    var left = try parse_expr_helper(tokens, cursor);

    while (true) {
        const op = tokens[cursor.*];

        if (op.kind == TokenKind.EOF) {
            break;
        }

        const i_bp = infix_bp(op.kind);
        const l_bp = i_bp.lvalue;
        const r_bp = i_bp.rvalue;
        if (min_bp > l_bp) {
            break;
        }

        const kind = parse_operator(tokens, cursor);

        const right = try parse_helper(tokens, cursor, r_bp);

        const lhs_ptr = try heap_alloc.create(Expr); // heap_alloc.alloc(type, number of elements)
        const rhs_ptr = try heap_alloc.create(Expr);

        lhs_ptr.* = left;
        rhs_ptr.* = right;

        const temp = ast.BinaryExpr{
            .op = kind,
            .ll = lhs_ptr,
            .rl = rhs_ptr,
        };
        left = Expr{ .binary = temp };
    }
    return left;
}

pub fn parse(tokens: []Token) !Expr {
    var cursor: usize = 0;
    return try parse_helper(tokens, &cursor, 0);
}
