const std = @import("std");
const builtin = @import("builtin");

const lib_extension = if (builtin.target.os.tag == .macos) ".dylib" else ".so";
const exe_extension = if (builtin.target.os.tag == .windows) ".exe" else "";
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
    _ = writer.addCopyFile(lib.getOutputSource(), "pdex" ++ lib_extension);

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
    const pdc_path = b.pathJoin(&.{ playdate_sdk_path, "bin", "pdc" ++ exe_extension });
    const pd_simulator_path = b.pathJoin(&.{ playdate_sdk_path, "bin", "PlaydateSimulator" ++ exe_extension });

    const pdc = b.addSystemCommand(&.{ pdc_path, "--skip-unknown" });
    pdc.addDirectorySourceArg(source_dir);
    pdc.setName("pdc" ++ exe_extension);
    const pdx = pdc.addOutputFileArg(pdx_file_name);

    b.installDirectory(.{
        .source_dir = pdx,
        .install_dir = .prefix,
        .install_subdir = pdx_file_name,
    });

    const run_cmd = b.addSystemCommand(&.{pd_simulator_path});
    run_cmd.setName("PlaydateSimulator");
    run_cmd.addDirectorySourceArg(pdx);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    //clean step
    {
        const clean_step = b.step("clean", "Clean all artifacts");
        const rm_zig_cache = b.addRemoveDirTree(b.cache_root.path orelse ".");
        clean_step.dependOn(&rm_zig_cache.step);
        const rm_zig_out = b.addRemoveDirTree(b.getInstallPath(.prefix, ""));
        clean_step.dependOn(&rm_zig_out.step);
    }
}
