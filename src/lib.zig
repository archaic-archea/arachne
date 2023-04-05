pub const framebuffer = @import("./framebuffer.zig");
pub const output = @import("./output.zig");
pub const pmm = @import("./memory/pmm.zig");

pub var freelist: pmm.FreeList = .{};
