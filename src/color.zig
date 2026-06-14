pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub const black = Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
    pub const white = Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    pub const red = Color{ .r = 255, .g = 0, .b = 0, .a = 255 };
    pub const green = Color{ .r = 0, .g = 255, .b = 0, .a = 255 };
    pub const blue = Color{ .r = 0, .g = 0, .b = 255, .a = 255 };

    pub fn fromGrey(v: u8) Color {
        return .{ .r = v, .g = v, .b = v, .a = 255 };
    }
};
