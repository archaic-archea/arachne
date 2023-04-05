const std = @import("std");

pub fn build(b: *std.Build) void {
    var target: std.zig.CrossTarget = .{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .none,
    };

    const Features = std.Target.x86.Feature;
    target.cpu_features_sub.addFeature(@enumToInt(Features.mmx));
    target.cpu_features_sub.addFeature(@enumToInt(Features.sse));
    target.cpu_features_sub.addFeature(@enumToInt(Features.sse2));
    target.cpu_features_sub.addFeature(@enumToInt(Features.avx));
    target.cpu_features_sub.addFeature(@enumToInt(Features.avx2));
    target.cpu_features_add.addFeature(@enumToInt(Features.soft_float));

    const optimize = b.standardOptimizeOption(.{});
    const kernel = b.addExecutable(.{
        .name = "arachne.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    kernel.code_model = .kernel;
    kernel.addAnonymousModule("limine", .{
        .source_file = .{ .path = "libs/limine.zig" },
    });
    kernel.setLinkerScriptPath(.{ .path = "config/linker.ld" });
    kernel.install();
}
