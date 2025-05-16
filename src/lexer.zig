const Token = @import("token.zig").Token;
const print = @import("std").debug.print;
const std = @import("std");

const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    read_pos: usize = 0,
    ch: u8 = 0,

    fn init(input: []const u8) Lexer {
        var lexer = Lexer{ .input = input };
        lexer.read_char();
        return lexer;
    }

    fn next_token(self: *Lexer) Token {
        self.skip_whitespace();
        var tok: Token = undefined;
        switch (self.ch) {
            '=' => tok = Token{ .type = .assign, .lexeme = "=" },
            ';' => tok = Token{ .type = .semicolon, .lexeme = ";" },
            '(' => tok = Token{ .type = .lparen, .lexeme = "(" },
            ')' => tok = Token{ .type = .rparen, .lexeme = ")" },
            ',' => tok = Token{ .type = .comma, .lexeme = "," },
            '+' => tok = Token{ .type = .plus, .lexeme = "+" },
            '{' => tok = Token{ .type = .lbrace, .lexeme = "{" },
            '}' => tok = Token{ .type = .rbrace, .lexeme = "}" },
            0 => return Token{ .type = .eof, .lexeme = "" },
            else => |c| if (is_digit(c)) {
                return self.read_num();
            } else if (is_letter(c)) {
                return self.read_ident();
            } else {
                self.debug_print();
                @panic("char not handled");
            },
        }
        self.read_char();
        return tok;
    }

    fn read_num(self: *Lexer) Token {
        const start = self.read_pos - 1;
        while (is_digit(self.ch)) {
            self.read_char();
        }
        return Token{
            .type = .int,
            .lexeme = self.input[start..self.position],
        };
    }

    fn read_ident(self: *Lexer) Token {
        const start = self.read_pos - 1;
        while (is_letter(self.ch)) {
            self.read_char();
        }
        const lexeme = self.input[start..self.position];
        return Token{
            .type = lookup_ident(lexeme),
            .lexeme = lexeme,
        };
    }

    fn read_char(self: *Lexer) void {
        if (self.read_pos >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_pos];
        }
        self.position = self.read_pos;
        self.read_pos += 1;
    }

    fn skip_whitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.read_char();
        }
    }

    fn debug_print(self: Lexer) void {
        print("Lexer: char=`{c}`, ch={d}, position={any}, read_pos={any}, input=`{s}`\n", .{
            self.ch,
            self.ch,
            self.position,
            self.read_pos,
            self.input,
        });
    }
};

fn lookup_ident(ident: []const u8) Token.Type {
    if (std.mem.eql(u8, ident, "fn")) {
        return .function;
    } else if (std.mem.eql(u8, ident, "let")) {
        return .let;
    } else {
        return .ident;
    }
}

fn is_digit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

fn is_letter(ch: u8) bool {
    return 'a' <= ch and ch <= 'z' or 'A' <= ch and ch <= 'Z' or ch == '_';
}

// tests

const t = @import("std").testing;

test "simple tokens" {
    var lexer = Lexer.init("=+(){},; 33");
    const tests = [_]Token{
        Token{ .type = .assign, .lexeme = "=" },
        Token{ .type = .plus, .lexeme = "+" },
        Token{ .type = .lparen, .lexeme = "(" },
        Token{ .type = .rparen, .lexeme = ")" },
        Token{ .type = .lbrace, .lexeme = "{" },
        Token{ .type = .rbrace, .lexeme = "}" },
        Token{ .type = .comma, .lexeme = "," },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .int, .lexeme = "33" },
        Token{ .type = .eof, .lexeme = "" },
    };
    for (tests) |expected| {
        const actual = lexer.next_token();
        try t.expectEqualStrings(expected.lexeme, actual.lexeme);
        try t.expectEqual(expected.type, actual.type);
    }
}

test "realistic tokens" {
    const monkey_code =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
    ;
    var lexer = Lexer.init(monkey_code);
    const tests = [_]Token{
        Token{ .type = .let, .lexeme = "let" },
        Token{ .type = .ident, .lexeme = "five" },
        Token{ .type = .assign, .lexeme = "=" },
        Token{ .type = .int, .lexeme = "5" },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .let, .lexeme = "let" },
        Token{ .type = .ident, .lexeme = "ten" },
        Token{ .type = .assign, .lexeme = "=" },
        Token{ .type = .int, .lexeme = "10" },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .let, .lexeme = "let" },
        Token{ .type = .ident, .lexeme = "add" },
        Token{ .type = .assign, .lexeme = "=" },
        Token{ .type = .function, .lexeme = "fn" },
        Token{ .type = .lparen, .lexeme = "(" },
        Token{ .type = .ident, .lexeme = "x" },
        Token{ .type = .comma, .lexeme = "," },
        Token{ .type = .ident, .lexeme = "y" },
        Token{ .type = .rparen, .lexeme = ")" },
        Token{ .type = .lbrace, .lexeme = "{" },
        Token{ .type = .ident, .lexeme = "x" },
        Token{ .type = .plus, .lexeme = "+" },
        Token{ .type = .ident, .lexeme = "y" },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .rbrace, .lexeme = "}" },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .let, .lexeme = "let" },
        Token{ .type = .ident, .lexeme = "result" },
        Token{ .type = .assign, .lexeme = "=" },
        Token{ .type = .ident, .lexeme = "add" },
        Token{ .type = .lparen, .lexeme = "(" },
        Token{ .type = .ident, .lexeme = "five" },
        Token{ .type = .comma, .lexeme = "," },
        Token{ .type = .ident, .lexeme = "ten" },
        Token{ .type = .rparen, .lexeme = ")" },
        Token{ .type = .semicolon, .lexeme = ";" },
        Token{ .type = .eof, .lexeme = "" },
    };
    for (tests) |expected| {
        const actual = lexer.next_token();
        try t.expectEqualStrings(expected.lexeme, actual.lexeme);
        try t.expectEqual(expected.type, actual.type);
    }
}
