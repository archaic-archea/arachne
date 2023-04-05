const limine = @import("limine");
const std = @import("std");

const lib = @import("./lib.zig");

pub export var FRAMEBUFFER: limine.FramebufferRequest = .{
    .revision = 1,
};
pub export var BOOTINFO: limine.BootloaderInfoRequest = .{};
pub export var MEMMAP: limine.MemoryMapRequest = .{};
pub export var HHDM: limine.HhdmRequest = .{};

fn kmain(kstdout: anytype) !void {
    var freelist = &lib.freelist;

    var bootinfo = BOOTINFO.response.?;
    var memmap = MEMMAP.response.?.entries();
    var hhdm = HHDM.response.?.offset;

    try kstdout.print("Booting Arachne with {s} v{s}\n", .{ bootinfo.name, bootinfo.version });
    try kstdout.print("Framebuffer revision {}\n", .{FRAMEBUFFER.response.?.revision});
    try kstdout.print("HHDM {x}\n", .{hhdm});

    var init = false;

    for (memmap) |entry| {
        try kstdout.print("Entry found {}\n", .{entry.kind});

        if (entry.kind == limine.MemoryMapEntryType.usable) {
            var frames = entry.length / 4096;

            for (0..frames) |frame_offset| {
                var base = entry.base + (frame_offset * 4096) + hhdm;
                var base_ptr = @intToPtr(*void, base);

                try kstdout.print("Pushing entry into freelist\n", .{});
                try kstdout.print("Entry base: {*}\n", .{base_ptr});
                if (init) {
                    freelist.push(base_ptr);
                } else {
                    freelist.init(base_ptr, kstdout);
                    init = true;
                }
            }
        }
    }

    try kstdout.print("Free pages: {}", .{freelist.length});

    done();
}

export fn _entry() callconv(.C) noreturn {
    const framebuffer = lib.framebuffer;

    var framebuf = FRAMEBUFFER.response.?.framebuffers()[0];

    var out: framebuffer.FrameWriter = .{
        .width = framebuf.width,
        .height = framebuf.height,
        .buffer = @ptrCast([*]framebuffer.Pixel, framebuf.address),
    };

    var framectx: lib.output.Kstdout = .{ .framewriter = out };

    var kstdout = framectx.writer();

    var result = kmain(kstdout);

    if (result) |_| {} else |err| {
        kstdout.print("Error occured with kernel {}", .{err}) catch {};
    }

    done();
}

inline fn done() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}
