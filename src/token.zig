const std = @import("std");

pub const Token = struct {
    type: Type,
    lexeme: []const u8,

    pub const Type = enum {
        illegal,
        eof,
        ident,
        int,
        assign,
        plus,
        comma,
        semicolon,
        lparen,
        rparen,
        lbrace,
        rbrace,
        function,
        let,
        lt,
        gt,
        bang,
        asterisk,
        slash,
        minus,
        true,
        false,
        iff,
        els,
        ret,
        eq,
        neq,
    };

    pub fn format(
        self: Token,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print(
            "Token(type=.{s}, lexeme=\"{s}\")",
            .{ @tagName(self.type), self.lexeme },
        );
    }
};
