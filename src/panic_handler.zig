const std = @import("std");
const pdapi = @import("playdate_api_definitions.zig");
const builtin = @import("builtin");

var global_playate: *pdapi.PlaydateAPI = undefined;
pub fn init(playdate: *pdapi.PlaydateAPI) void {
    global_playate = playdate;
}
pub fn panic(
    msg: []const u8,
    error_return_trace: ?*std.builtin.StackTrace,
    return_address: ?usize,
) noreturn {
    _ = error_return_trace;
    _ = return_address;

    switch (comptime builtin.os.tag) {
        .freestanding => {
            //Playdate hardware

            //TODO(Daniel Bokser): The Zig std library does not yet support stacktraces on Playdate hardware.
            //We will need to do this manually. Some notes on trying to get it working:
            //Frame pointer is R7
            //Next Frame pointer is *R7
            //Return address is *(R7+4)
            //To print out the trace corrently,
            //We need to know the load address and it doesn't seem to be exactly
            //0x6000_0000 as originally thought

            global_playate.system.@"error"("PANIC: %s", msg.ptr);
        },
        else => {
            //playdate simulator

            //TODO(Daniel Bokser): As of Playdate OS 3.0.0, the simulator no longer exits with the
            //   global_playate.system.@"error"() API. As a result, the simulator would hang when a panic
            //   occurs due to a infinite loop at the end of this function. This also makes the commented
            //   code below useless.
            //
            //   I have decided to replace the infinite loop at the bottom with a @breakpoint() call.
            //   This will crash the simulator, which is more immediate feedback than the simulator hanging.
            //   If you run the simulator in a debugger, the debugger will automatically break at the @breakpoint() call.
            //
            //   I am told Panic does have an exit() API forthcoming.  Once that is there, I can
            //   uncomment the code below, and hopefully finally fix
            //   https://github.com/DanB91/Zig-Playdate-Template/issues/13

            // var stack_trace_buffer = [_]u8{0} ** 4096;
            // var buffer = [_]u8{0} ** 4096;
            // var stream = std.io.Writer.fixed(&stack_trace_buffer);

            // const stack_trace_string = b: {
            //     if (builtin.strip_debug_info) {
            //         break :b "Unable to dump stack trace: Debug info stripped";
            //     }
            //     const debug_info = std.debug.getSelfDebugInfo() catch |err| {
            //         const to_print = std.fmt.bufPrintZ(
            //             &buffer,
            //             "Unable to dump stack trace: Unable to open debug info: {s}\n",
            //             .{@errorName(err)},
            //         ) catch break :b "Unable to dump stack trace: Unable to open debug info due unknown error";
            //         break :b to_print;
            //     };
            //     std.debug.writeCurrentStackTrace(
            //         &stream,
            //         debug_info,
            //         .no_color,
            //         null,
            //     ) catch break :b "Unable to dump stack trace: Unknown error writng stack trace";

            //     //NOTE: playdate.system.error (and all Playdate APIs that deal with strings) require a null termination
            //     stack_trace_buffer[stack_trace_buffer.len - 1] = 0;

            //     break :b &stack_trace_buffer;
            // };
            // global_playate.system.@"error"(
            //     "PANIC: %s\n\n%s",
            //     msg.ptr,
            //     stack_trace_string.ptr,
            // );
        },
    }

    @breakpoint();
    @trap();
}
