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
    };
};
