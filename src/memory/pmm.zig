// Every pmm entry will just be 1 page, and when you attempt to return a page, you will add it like a new entry

const memory = @import("./memory.zig");
const lib = @import("../lib.zig");

pub const FreeEntry = struct {
    prev: ?memory.VirtualAddress,
    next: ?memory.VirtualAddress,
};

pub const FreeList = struct {
    length: u64 = 0,
    head: ?memory.VirtualAddress = null,
    tail: ?memory.VirtualAddress = null,

    /// Initializes a new entry for a hopefully uninitialized list
    pub fn init(self: *FreeList, base: *void, kstdout: anytype) void {
        var aligned = @alignCast(8, base);

        kstdout.print("Address aligned\n", .{}) catch {};

        // Get the address as a u64
        var addr = @ptrToInt(aligned);
        // Get the address as a free entry pointer
        var entry_base = @ptrCast(*FreeEntry, aligned);

        kstdout.print("Address managed, writing: {*}\n", .{entry_base}) catch {};

        // Set it as the new head, make sure tail is null, and length is 1
        self.head.?.full = addr;
        kstdout.print("Head set\n", .{}) catch {};
        self.tail = null;
        kstdout.print("Tail nulled\n", .{}) catch {};
        self.length = 1;
        kstdout.print("Length set\n", .{}) catch {};

        // Null next and prev entries on the new entry
        entry_base.next = null;
        entry_base.prev = null;
    }

    /// Pushes a new entry onto the end
    pub fn push(self: *FreeList, base: *void) void {
        // Get the address as a u64
        var addr = @ptrToInt(base);
        // Get the address as a free entry pointer
        var entry_base = @ptrCast(*FreeEntry, @alignCast(8, base));

        // Get previous tail and store it as the previous entry
        var prev_tail = self.tail.?;
        entry_base.prev = prev_tail;

        // Null the next entry
        entry_base.next = null;

        // Store new tail, increment length
        self.tail.?.full = addr;
        self.length += 1;
    }

    /// Removes an entry and provides a pointer to its base
    pub fn remove(self: *FreeList, idx: u64) ?*void {
        var ptr = self.index(idx);

        if (ptr == null) {
            return null;
        } else {
            return @ptrCast(*void, ptr.?);
        }
    }

    /// Returns a pointer to an entry, if it exists
    pub fn index(self: *FreeList, idx: u64) ?*FreeEntry {
        var virt_addr = self.head;

        if (virt_addr == null) {
            return null;
        }

        for (0..idx) |_| {
            var pointer = @intToPtr(*FreeEntry, virt_addr.full);
            virt_addr = pointer.next.?;

            if (virt_addr == null) {
                return null;
            }
        }

        return @intToPtr(*FreeEntry, virt_addr.?.full);
    }
};
