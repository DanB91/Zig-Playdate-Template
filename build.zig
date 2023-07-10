const std = @import("std");

const os_tag = @import("builtin").os.tag;
const name = "example";
pub fn build(b: *std.build.Builder) !void {
    const pdx_file_name = name ++ ".pdx";
    const optimize = b.standardOptimizeOption(.{});

    const writer = b.addWriteFiles();
    const source_dir = writer.getDirectorySource();
    writer.step.name = "write source directory";

    const lib = b.addSharedLibrary(.{
        .name = "pdex",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
        .target = .{},
    });
    _ = writer.addCopyFile(lib.getOutputSource(), "pdex" ++ if (os_tag == .macos) ".dylib" else ".so");

    const playdate_target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "thumb-freestanding-eabihf",
        .cpu_features = "cortex_m7-fp64-fp_armv8d16-fpregs64-vfp2-vfp3d16-vfp4d16",
    });
    const elf = b.addExecutable(.{
        .name = "pdex.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = playdate_target,
        .optimize = optimize,
    });
    elf.force_pic = true;
    elf.link_emit_relocs = true;
    elf.setLinkerScriptPath(.{ .path = "link_map.ld" });
    if (optimize == .ReleaseFast) {
        elf.omit_frame_pointer = true;
    }
    _ = writer.addCopyFile(elf.getOutputSource(), "pdex.elf");

    // WriteFile doesn't support copying whole directories.
    var assets = try b.build_root.handle.openIterableDir("assets", .{});
    defer assets.close();
    var iter = assets.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        const file_source = .{ .path = b.pathJoin(&.{ "assets", entry.name }) };
        _ = writer.addCopyFile(file_source, entry.name);
    }

    const playdate_sdk_path = try std.process.getEnvVarOwned(b.allocator, "PLAYDATE_SDK_PATH");
    const pdc_path = b.pathJoin(&.{ playdate_sdk_path, "bin", if (os_tag == .windows) "pdc.exe" else "pdc" });
    const pd_simulator_path = switch (os_tag) {
        .linux => b.pathJoin(&.{ playdate_sdk_path, "bin", "PlaydateSimulator" }),
        .macos => "open", // `open` focuses the window, while running the simulator directry doesn't.
        .windows => b.pathJoin(&.{ playdate_sdk_path, "bin", "PlaydateSimulator.exe" }),
        else => @panic("Unsupported OS"),
    };

    const pdc = b.addSystemCommand(&.{ pdc_path, "--skip-unknown" });
    pdc.addDirectorySourceArg(source_dir);
    pdc.setName("pdc");
    const pdx = pdc.addOutputFileArg(pdx_file_name);

    b.installDirectory(.{
        .source_dir = pdx,
        .install_dir = .prefix,
        .install_subdir = pdx_file_name,
    });

    const run_cmd = b.addSystemCommand(&.{pd_simulator_path});
    run_cmd.addDirectorySourceArg(pdx);
    run_cmd.setName("PlaydateSimulator");
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    run_step.dependOn(b.getInstallStep());

    const clean_step = b.step("clean", "Clean all artifacts");
    clean_step.dependOn(b.getUninstallStep());
    clean_step.dependOn(&b.addRemoveDirTree(b.cache_root.path orelse ".").step);
}
