const Token = @import("token.zig").Token;
const print = @import("std").debug.print;

const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    read_pos: usize = 0,
    ch: u8 = 0,

    fn init(input: []const u8) Lexer {
        return Lexer{ .input = input };
    }

    fn next_token(self: *Lexer) Token {
        self.read_char();
        return Token{ .type = .eof, .lexeme = "" };
    }

    fn read_char(self: *Lexer) void {
        if (self.read_pos >= self.input.len) {
            self.ch = 0;
        }
    }
};

// tests

const t = @import("std").testing;
const OhSnap = @import("ohsnap");

test "lexer next token" {
    const oh = OhSnap{};
    const input = "=+(){},;";
    var lexer = Lexer.init(input);
    const tests = [_]Token{
        Token{ .type = .assign, .lexeme = "=" },
        Token{ .type = .plus, .lexeme = "+" },
        Token{ .type = .lparen, .lexeme = "(" },
        Token{ .type = .rparen, .lexeme = ")" },
        Token{ .type = .lbrace, .lexeme = "{" },
        Token{ .type = .rbrace, .lexeme = "}" },
        Token{ .type = .comma, .lexeme = "," },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .eof, .lexeme = "" },
    };
    for (tests) |expected| {
        _ = expected;
        const actual = lexer.next_token();
        try oh.snap(
            @src(),
            \\
            ,
        ).expectEqual(actual);
    }
}
