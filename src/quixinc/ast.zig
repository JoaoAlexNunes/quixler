pub const UnOp = enum {
    neg,
};

pub const BinOp = enum {
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

pub const UnaryExpr = struct {
    op: UnOp,
    leaf: *const Expr,
};

pub const BinaryExpr = struct {
    op: BinOp,
    ll: *const Expr, // left  leaf
    rl: *const Expr, // right leaf
};

pub const Expr = union(ExprTy) {
    atomic: f64,
    unary: UnaryExpr,
    binary: BinaryExpr,
};

pub fn eval(expr: *const Expr) f64 {
    return switch (expr.*) {
        ExprTy.atomic => |v| @as(f64, v),
        ExprTy.unary => |u| {
            const leaf = eval(u.leaf);
            return switch (u.op) {
                UnOp.neg => -leaf,
            };
        },
        ExprTy.binary => |b| {
            const ll = eval(b.ll);
            const rl = eval(b.rl);
            return switch (b.op) {
                BinOp.add => ll + rl,
                BinOp.sub => ll - rl,
                BinOp.mul => ll * rl,
                BinOp.div => ll / rl,
            };
        },
    };
}
