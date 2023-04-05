pub const VirtualAddress = packed union {
    full: u64,
    segmented4: VirtFields4,
    segmented5: VirtFields5,
};

const VirtFields4 = packed struct {
    offset: u12,
    table: u9,
    dir: u9,
    dir_ptr: u9,
    pml4: MaxPageLevel,
};

const VirtFields5 = packed struct {
    offset: u12,
    table: u9,
    dir: u9,
    dir_ptr: u9,
    pml4: u9,
    pml5: MaxPageLevel,
};

const MaxPageLevel = packed union { full: u9, segmented: MaxPageLevelFields };

const MaxPageLevelFields = packed struct { base: u8, sign: bool };
