const std = @import("std");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn init(r: u8, g: u8, b: u8, a: u8) Color {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }
};

pub fn rgb(r: u8, g: u8, b: u8) Color {
    return .{ .r = r, .g = g, .b = b, .a = 255 };
}

pub fn pack(c: Color) u32 {
    return (@as(u32, c.a) << 24) |
        (@as(u32, c.r) << 16) |
        (@as(u32, c.g) << 8) |
        (@as(u32, c.b));
}

pub fn unpack(p: u32) Color {
    return .{
        .a = @intCast((p >> 24) & 0xFF),
        .r = @intCast((p >> 16) & 0xFF),
        .g = @intCast((p >> 8) & 0xFF),
        .b = @intCast(p & 0xFF),
    };
}

test "color pack" {
    const expected: u32 = 0xFFFFFFFF;
    const in: Color = .{ .r = 255, .g = 255, .b = 255, .a = 255 };
    const res: u32 = pack(in);
    try std.testing.expectEqual(expected, res);
}

test "color unpack" {
    const expected: Color = .{ .r = 255, .g = 255, .b = 255, .a = 255 };
    const in: u32 = 0xFFFFFFFF;
    const res: Color = unpack(in);
    try std.testing.expectEqual(expected, res);
}
