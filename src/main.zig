const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;

pub fn main() !void {
    std.debug.print("Welcome to Monkey!\n", .{});
    while (true) {
        std.debug.print(">> ", .{});
        const stdin = std.io.getStdIn().reader();
        const line = try stdin.readUntilDelimiterAlloc(
            std.heap.page_allocator,
            '\n',
            8192,
        );
        var lexer = Lexer.init(line);
        while (true) {
            const token = lexer.next_token();
            std.debug.print("{any}\n", .{token});
            if (token.type == .eof) break;
        }

        defer std.heap.page_allocator.free(line);
    }
}
