const Vec2 = @import("../core/math.zig").Vec2;

pub const ScreenVertex = struct {
    position: Vec2,
    z: f32,
};
