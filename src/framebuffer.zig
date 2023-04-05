const limine = @import("limine");
const font = @import("./font.zig");

pub const FrameWriter = struct {
    x: u64 = 0,
    y: u64 = 0,
    xtra_x: u64 = 0,
    xtra_y: u64 = 0,
    width: u64 = 0,
    height: u64 = 0,
    buffer: [*]Pixel,
    format: Format = .RGBA,

    pub fn writeString(self: *FrameWriter, str: []const u8) void {
        for (str) |character| {
            if (character != '\n') {
                self.writeChar(character);
            } else {
                self.x = 0;
                self.change_y(8);
            }
        }
    }

    pub fn writePixel(self: *FrameWriter, data: Pixel, x: u64, y: u64) void {
        var pix_offset = x + (self.width * y);
        self.buffer[pix_offset] = data;
    }

    pub fn writeChar(self: *FrameWriter, character: u8) void {
        var char_dat = font.BasicFont[character];

        var xtra_x: u64 = 0;
        var xtra_y: u64 = 0;
        for (char_dat) |byte| {
            for (0..8) |bit_idx| {
                var bit = (byte >> @intCast(u3, bit_idx)) & 0b1;

                if (bit == 1) {
                    self.writePixel(
                        Pixel.new(0xff, 0xff, 0xff, 0xff, self.format),
                        xtra_x + self.x,
                        xtra_y + self.y,
                    );
                }

                xtra_x += 1;
            }

            xtra_x = 0;
            xtra_y += 1;
        }

        self.change_x(8);
    }

    pub fn offset(self: *FrameWriter) u64 {
        var x = self.x + self.xtra_x;
        var y = self.y + self.xtra_y;

        return x + (y * self.width);
    }

    pub fn change_x(self: *FrameWriter, change: isize) void {
        self.x += @intCast(u64, change);
        self.y += (self.x / self.width) * 8;
        self.x = self.x % self.width;
    }

    pub fn change_y(self: *FrameWriter, change: isize) void {
        self.y += @intCast(u64, change);
        self.y = self.y % self.height;
    }
};

pub const Pixel = struct {
    data: [4]u8,

    pub fn new(red: u8, green: u8, blue: u8, alpha: u8, format: Format) Pixel {
        switch (format) {
            .RGBA => {
                var pix: Pixel = .{
                    .data = [4]u8{
                        red,
                        green,
                        blue,
                        alpha,
                    },
                };

                return pix;
            },
        }
    }
};

pub const Format = enum {
    RGBA,
};
