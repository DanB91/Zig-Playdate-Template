const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) !void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const pdx_file_name = "example.pdx";

    const lib = b.addSharedLibrary("pdex", "src/main.zig", .unversioned);

    const output_path = try std.fs.path.join(b.allocator, &.{ b.install_path, "Source" });
    lib.setOutputDir(output_path);

    lib.setBuildMode(mode);
    lib.install();

    const game_elf = b.addExecutable("pdex.elf", "src/playdate_hardware_main.zig");
    game_elf.step.dependOn(&lib.step);
    game_elf.link_function_sections = true;
    game_elf.stack_size = 61800;
    game_elf.setLinkerScriptPath(.{ .path = "link_map.ld" });
    game_elf.setOutputDir(b.install_path);
    game_elf.setBuildMode(mode);
    const playdate_target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "thumb-freestanding-eabihf",
        .cpu_features = "cortex_m7-fp64-fp_armv8d16-fpregs64-vfp2-vfp3d16-vfp4d16",
    });
    game_elf.setTarget(playdate_target);
    if (b.is_release) {
        game_elf.omit_frame_pointer = true;
    }
    game_elf.install();

    const playdate_sdk_path = try std.process.getEnvVarOwned(b.allocator, "PLAYDATE_SDK_PATH");
    //const home_path = try std.process.getEnvVarOwned(b.allocator, if (builtin.target.os.tag == .windows) "USERPROFILE" else "HOME");

    switch (builtin.target.os.tag) {
        .windows => {
            const copy_assets = b.addSystemCommand(&.{ "cp", "assets/playdate_image.png", "zig-out/Source" });
            copy_assets.step.dependOn(&game_elf.step);
            const emit_device_binary = b.addSystemCommand(&.{ "arm-none-eabi-objcopy", "-Obinary", "zig-out/pdex.elf", "zig-out/Source/pdex.bin" });
            emit_device_binary.step.dependOn(&copy_assets.step);
            const pdc_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/pdc.exe", .{playdate_sdk_path});
            const pdc = b.addSystemCommand(&.{ pdc_path, "--skip-unknown", "zig-out/Source", "zig-out/" ++ pdx_file_name });
            pdc.step.dependOn(&emit_device_binary.step);
            b.getInstallStep().dependOn(&pdc.step);

            const pd_simulator_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/PlaydateSimulator.exe", .{playdate_sdk_path});
            const run_cmd = b.addSystemCommand(&.{ pd_simulator_path, "zig-out/" ++ pdx_file_name });
            run_cmd.step.dependOn(&pdc.step);
            const run_step = b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
        },
        .macos => {
            const rename_dylib = b.addSystemCommand(&.{ "mv", "zig-out/Source/libpdex.dylib", "zig-out/Source/pdex.dylib" });
            rename_dylib.step.dependOn(&game_elf.step);
            const copy_assets = b.addSystemCommand(&.{ "cp", "assets/playdate_image.png", "zig-out/Source" });
            copy_assets.step.dependOn(&rename_dylib.step);
            const emit_device_binary = b.addSystemCommand(&.{ "objcopy", "-Obinary", "zig-out/pdex.elf", "zig-out/Source/pdex.bin" });
            emit_device_binary.step.dependOn(&copy_assets.step);
            const pdc_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/pdc", .{playdate_sdk_path});
            const pdc = b.addSystemCommand(&.{ pdc_path, "--skip-unknown", "zig-out/Source", "zig-out/" ++ pdx_file_name });
            pdc.step.dependOn(&emit_device_binary.step);
            b.getInstallStep().dependOn(&pdc.step);

            const run_cmd = b.addSystemCommand(&.{ "open", "zig-out/" ++ pdx_file_name });
            run_cmd.step.dependOn(&pdc.step);
            const run_step = b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
        },
        .linux => {
            const rename_so = b.addSystemCommand(&.{ "mv", "zig-out/Source/libpdex.so", "zig-out/Source/pdex.so" });
            rename_so.step.dependOn(&game_elf.step);
            const copy_assets = b.addSystemCommand(&.{ "cp", "assets/playdate_image.png", "zig-out/Source" });
            copy_assets.step.dependOn(&rename_so.step);
            const emit_device_binary = b.addSystemCommand(&.{ "arm-none-eabi-objcopy", "-Obinary", "zig-out/pdex.elf", "zig-out/Source/pdex.bin" });
            emit_device_binary.step.dependOn(&copy_assets.step);
            const pdc_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/pdc", .{playdate_sdk_path});
            const pdc = b.addSystemCommand(&.{ pdc_path, "--skip-unknown", "zig-out/Source", "zig-out/" ++ pdx_file_name });
            pdc.step.dependOn(&emit_device_binary.step);
            b.getInstallStep().dependOn(&pdc.step);

            const pd_simulator_path = try std.fmt.allocPrint(b.allocator, "{s}/bin/PlaydateSimulator", .{playdate_sdk_path});
            const run_cmd = b.addSystemCommand(&.{ pd_simulator_path, "zig-out/" ++ pdx_file_name });
            run_cmd.step.dependOn(&pdc.step);
            const run_step = b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
        },
        else => {
            @panic("Unsupported OS!");
        },
    }
}
