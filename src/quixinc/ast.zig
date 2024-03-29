pub const OperatorKind = enum {
    add,
    sub,
    mul,
    div,
};

const ExprTy = enum {
    atomic,
    unary,
    binary,
};

pub const BinaryExpr = struct {
    op: OperatorKind,
    ll: *const Expr, // left  leaf
    rl: *const Expr, // right leaf
};

pub const UnaryExpr = struct { op: OperatorKind, expr: *const Expr };

//Tree
pub const Expr = union(ExprTy) {
    atomic: f64,
    unary: UnaryExpr,
    binary: BinaryExpr,
};

pub fn eval(expr: *const Expr) f64 {
    return switch (expr.*) {
        Expr.atomic => |v| @as(f64, v),
        Expr.unary => |u| {
            const leaf = eval(u.expr);
            return switch (u.op) {
                OperatorKind.sub => -leaf,
                else => unreachable,
            };
        },
        Expr.binary => |b| {
            const ll = eval(b.ll);
            const rl = eval(b.rl);
            return switch (b.op) {
                OperatorKind.add => ll + rl,
                OperatorKind.sub => ll - rl,
                OperatorKind.mul => ll * rl,
                OperatorKind.div => ll / rl,
            };
        },
    };
}
