# TODO
- setup render module files and adjust imports


# Planned Project Structure



src/
  main.zig

  core/
    math.zig        (vec3, mat4)
    mesh.zig        (Vertex, Triangle, Mesh)
    obj_loader.zig

  render/
    framebuffer.zig
    renderer.zig
    rasterizer.zig
    pipeline.zig

  scene/
    model.zig
    camera.zig

  platform/
    raylib_backend.zig
