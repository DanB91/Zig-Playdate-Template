const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});

    const pdx_file_name = "example.pdx";

    const lib = b.addSharedLibrary(.{
        .name = "pdex",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
        .target = .{},
    });

    const output_path = "Source";
    const lib_step = b.addInstallArtifact(lib);
    lib_step.dest_dir = .{ .custom = output_path };

    const playdate_target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "thumb-freestanding-eabihf",
        .cpu_features = "cortex_m7-fp64-fp_armv8d16-fpregs64-vfp2-vfp3d16-vfp4d16",
    });
    const game_elf = b.addExecutable(.{
        .name = "pdex.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = playdate_target,
        .optimize = optimize,
    });
    game_elf.step.dependOn(&lib_step.step);
    game_elf.force_pic = true;
    game_elf.link_emit_relocs = true;
    game_elf.setLinkerScriptPath(.{ .path = "link_map.ld" });
    const game_elf_step = b.addInstallArtifact(game_elf);
    game_elf_step.dest_dir = .{ .custom = output_path };
    if (optimize == .ReleaseFast) {
        game_elf.omit_frame_pointer = true;
    }

    const playdate_sdk_path = try std.process.getEnvVarOwned(b.allocator, "PLAYDATE_SDK_PATH");

    var previous_step = &game_elf_step.step;
    if (remove_lib_prefix_step(b)) |step| {
        step.step.dependOn(&game_elf_step.step);
        previous_step = &step.step;
    }
    const copy_assets = b.addSystemCommand(&.{ "cp", "assets/playdate_image.png", "assets/pdxinfo", "assets/icon.png", "zig-out/Source" });
    copy_assets.step.dependOn(previous_step);
    const pdc_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/pdc{s}", .{
        playdate_sdk_path,
        if (builtin.target.os.tag == .windows) ".exe" else "",
    });
    const pdc = b.addSystemCommand(&.{ pdc_path, "--skip-unknown", "zig-out/Source", "zig-out/" ++ pdx_file_name });
    pdc.step.dependOn(&copy_assets.step);
    b.getInstallStep().dependOn(&pdc.step);

    const run_cmd = b: {
        switch (builtin.target.os.tag) {
            .windows => {
                const pd_simulator_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/PlaydateSimulator.exe", .{playdate_sdk_path});
                break :b b.addSystemCommand(&.{ pd_simulator_path, "zig-out/" ++ pdx_file_name });
            },
            .macos => {
                break :b b.addSystemCommand(&.{ "open", "zig-out/" ++ pdx_file_name });
            },
            .linux => {
                const pd_simulator_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/PlaydateSimulator", .{playdate_sdk_path});
                break :b b.addSystemCommand(&.{ pd_simulator_path, "zig-out/" ++ pdx_file_name });
            },
            else => {
                @panic("Unsupported OS!");
            },
        }
    };
    run_cmd.step.dependOn(&pdc.step);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    //clean step
    {
        const clean_step = b.step("clean", "Clean all artifacts");
        const rm_zig_cache = b.addRemoveDirTree("zig-cache");
        clean_step.dependOn(&rm_zig_cache.step);
        const rm_zig_out = b.addRemoveDirTree("zig-out");
        clean_step.dependOn(&rm_zig_out.step);
    }
}

fn remove_lib_prefix_step(b: *std.build.Builder) ?*std.build.Step.Run {
    const extension = if (builtin.target.os.tag == .macos) "dylib" else "so";
    return switch (builtin.target.os.tag) {
        .macos, .linux => b.addSystemCommand(&.{ "mv", "zig-out/Source/libpdex." ++ extension, "zig-out/Source/pdex." ++ extension }),
        else => null,
    };
}
