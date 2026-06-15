pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub fn scale(v: Vec3, s: f32) Vec3 {
        return .{
            .x = v.x * s,
            .y = v.y * s,
            .z = v.z * s,
        };
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn lengthSquared(v: Vec3) f32 {
        return dot(v, v);
    }

    pub fn length(v: Vec3) f32 {
        return @sqrt(lengthSquared(v));
    }

    pub fn normalized(v: Vec3) Vec3 {
        const len = v.length();
        return scale(v, 1.0 / len);
    }
};

pub const Vec3int = struct {
    x: i32,
    y: i32,
    z: i32,

    pub fn init(x: i32, y: i32, z: i32) Vec3int {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn fromVec3(v: Vec3) Vec3int {
        return .{
            .x = @intFromFloat(v.x),
            .y = @intFromFloat(v.y),
            .z = @intFromFloat(v.z),
        };
    }
};
