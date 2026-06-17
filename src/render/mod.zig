pub const framebuffer = @import("framebuffer.zig");
pub const rasterizer = @import("rasterizer.zig");
pub const renderer = @import("renderer.zig");

const Vec2 = @import("../core/math.zig").Vec2;

pub const ScreenVertex = struct {
    position: Vec2,
    z: f32,
};

pub const ScreenBoundingBox = struct {
    min_x: i32,
    max_x: i32,
    min_y: i32,
    max_y: i32,
};

test {
    _ = framebuffer;
    _ = rasterizer;
    _ = renderer;
}
