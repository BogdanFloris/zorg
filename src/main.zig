const std = @import("std");
const glfw = @import("mach_glfw");
const gl = @import("gl");

var gl_procs: gl.ProcTable = undefined;

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

fn keyCallback(window: glfw.Window, key: glfw.Key, _: i32, action: glfw.Action, _: glfw.Mods) void {
    if (key == .escape and action == .press) {
        window.setShouldClose(true);
    }
}

fn framebufferSizeCallback(_: glfw.Window, width: u32, height: u32) void {
    gl.Viewport(0, 0, @intCast(width), @intCast(height));
}

/// Key callback
pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        return error.GLFWInitFailed;
    }
    defer glfw.terminate();
    std.log.info("initialized GLFW on platform {s}\n", .{@tagName(glfw.getPlatform())});

    // Create our window
    const window: glfw.Window = glfw.Window.create(800, 600, "zorg", null, null, .{ .context_version_major = gl.info.version_major, .context_version_minor = gl.info.version_minor, .opengl_profile = .opengl_core_profile, .opengl_forward_compat = true }) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        return error.CreateWindowFailed;
    };
    defer window.destroy();

    // Set Window callbacks
    window.setKeyCallback(keyCallback);
    window.setFramebufferSizeCallback(framebufferSizeCallback);

    // Make the window's OpenGL context current.
    glfw.makeContextCurrent(window);
    defer glfw.makeContextCurrent(null);

    // Enable VSync to avoid drawing more often than necessary.
    glfw.swapInterval(1);

    // Initialize the OpenGL procedure table.
    if (!gl_procs.init(glfw.getProcAddress)) {
        std.log.err("failed to load OpenGL functions", .{});
        return error.GLInitFailed;
    }
    // Make the OpenGL procedure table current.
    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    // Set viewport
    gl.Viewport(0, 0, 800, 600);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        window.swapBuffers();
        glfw.pollEvents();
    }
}
