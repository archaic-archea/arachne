const std = @import("std");
const framebuffer = @import("./framebuffer.zig");

pub const KoutErr = error{
    Unknown,
};

pub const Kstdout = struct {
    framewriter: framebuffer.FrameWriter,

    pub const Writer = std.io.Writer(
        *Kstdout,
        KoutErr,
        derefWrite,
    );

    pub fn derefWrite(
        self: *Kstdout,
        string: []const u8,
    ) KoutErr!usize {
        self.framewriter.writeString(string);

        return string.len;
    }

    pub fn writer(self: *Kstdout) Writer {
        return .{ .context = self };
    }
};
