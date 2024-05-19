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

            //TODO: The Zig std library does not yet support stacktraces on Playdate hardware.
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
            var stack_trace_buffer = [_]u8{0} ** 4096;
            var buffer = [_]u8{0} ** 4096;
            var stream = std.io.fixedBufferStream(&stack_trace_buffer);

            const stack_trace_string = b: {
                if (builtin.strip_debug_info) {
                    break :b "Unable to dump stack trace: Debug info stripped";
                }
                const debug_info = std.debug.getSelfDebugInfo() catch |err| {
                    const to_print = std.fmt.bufPrintZ(
                        &buffer,
                        "Unable to dump stack trace: Unable to open debug info: {s}\n",
                        .{@errorName(err)},
                    ) catch break :b "Unable to dump stack trace: Unable to open debug info due unknown error";
                    break :b to_print;
                };
                std.debug.writeCurrentStackTrace(
                    stream.writer(),
                    debug_info,
                    .no_color,
                    null,
                ) catch break :b "Unable to dump stack trace: Unknown error writng stack trace";

                //NOTE: playdate.system.error (and all Playdate APIs that deal with strings) require a null termination
                const null_char_index = @min(stream.pos, stack_trace_buffer.len - 1);
                stack_trace_buffer[null_char_index] = 0;

                break :b &stack_trace_buffer;
            };
            global_playate.system.@"error"(
                "PANIC: %s\n\n%s",
                msg.ptr,
                stack_trace_string.ptr,
            );
        },
    }

    while (true) {}
}
