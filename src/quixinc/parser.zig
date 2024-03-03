const std = @import("std");
const ast = @import("ast.zig");
const lex = @import("lexer.zig");
const ArrayList = std.ArrayList;

const Expr = ast.Expr;
const Token = lex.Token;
const TokenKind = lex.TokenKind;

const Bptype = union { int: i8, void: void };

const Bpvalue = struct { lvalue: Bptype, rvalue: Bptype };

fn prefix_bp(kind: TokenKind) Bpvalue {
    switch (kind) {
        TokenKind.Sub => {
            Bpvalue{ .lvalue = void, .rvalue = 5 };
        },
    }
}

fn infix_bp(kind: TokenKind) Bpvalue {
    switch (kind) {
        TokenKind.Add | TokenKind.Sub => {
            Bpvalue{ .lvalue = 1, .rvalue = 2 };
        },
        TokenKind.Mul | TokenKind.Div => {
            Bpvalue{ .lvalue = 3, .rvalue = 4 };
        },
    }
}

fn parse_primary(token: Token) Expr {
    switch (token.kind) {
        TokenKind.Atomic => Expr.Atomic,
    }
}

// fn parse_primary(tokens: &[Token], cursor: &mut usize) -> Expr {
//     let current_token = &tokens[*cursor];
//     *cursor += 1;

//     match current_token.kind {
//         TokenKind::Number => Expr::Number(current_token.value.parse().unwrap()),
//         _ => panic!(
//             "Primary Expression Expected but found {:?}",
//             current_token.kind
//         ),
//     }
// }

// fn parse_operator(tokens: &[Token], cursor: &mut usize) -> OperatorKind {
//     let current_token = &tokens[*cursor];
//     *cursor += 1;

//     match current_token.kind {
//         TokenKind::Addition => OperatorKind::Add,
//         TokenKind::Subtraction => OperatorKind::Sub,
//         TokenKind::Multiplication => OperatorKind::Mul,
//         TokenKind::Div => OperatorKind::Div,
//         _ => panic!(
//             "Operator Expression Expected but found {:?}",
//             current_token.kind
//         ),
//     }
// }

// // recursive descent parser
// pub fn parse(tokens: &[Token], cursor: &mut usize, min_bp: u8) -> Expr {
//     let mut left = match tokens[*cursor].kind {
//         TokenKind::Number => parse_primary(tokens, cursor),
//         TokenKind::Subtraction => {
//             let ((), r_bp) = prefix_bp(&TokenKind::Subtraction);
//             let kind = parse_operator(tokens, cursor);
//             let right = parse(&tokens, cursor, r_bp);

//             Expr::Unary {
//                 kind,
//                 operand: Box::new(right),
//             }
//         }
//         _ => panic!("Unexpected token {:?}", tokens[*cursor].kind),
//     };

//     loop {
//         // iterate over all the tokens...
//         let op = &tokens[*cursor];

//         if op.kind == TokenKind::EOF {
//             break;
//         }

//         let (l_bp, r_bp) = infix_bp(&op.kind);
//         if min_bp > l_bp {
//             break;
//         }

//         let kind = parse_operator(tokens, cursor);

//         let right = parse(&tokens, cursor, r_bp);

//         left = Expr::Binary {
//             kind,
//             left: Box::new(left),
//             right: Box::new(right),
//         }
//     }

//     left
// }
