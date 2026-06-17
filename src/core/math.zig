const std = @import("std");
const rl = @import("raylib");

pub const Vec3 = rl.Vector3;
pub const Vec4 = rl.Vector4;
pub const Mat4 = rl.Matrix;

pub const Vec3i = struct {
    x: i32,
    y: i32,
    z: i32,

    pub fn init(x: i32, y: i32, z: i32) Vec3i {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn fromVec3(v: Vec3) Vec3i {
        return .{
            .x = @intFromFloat(v.x),
            .y = @intFromFloat(v.y),
            .z = @intFromFloat(v.z),
        };
    }
};

pub const Vec2 = struct {
    x: f32,
    y: f32,
};

pub const Vec2i = struct {
    x: i32,
    y: i32,
};

pub fn Vec3Transform(m: Mat4, v: Vec3) Vec3 {
    return v.transform(m);
}

pub fn degToRad(deg: f32) f32 {
    return deg * std.math.pi / 180.0;
}
