const pdapi = @import("playdate_api_definitions.zig");
const main = @import("main.zig");

comptime {
    asm (
        \\.global _bss_start
        \\.global _bss_end
        \\.extern __bss_start__
        \\.extern __bss_end__
        \\.section .bss_start
        \\_bss_start:
        \\    .word __bss_start__
        \\.section .bss_end
        \\_bss_end:
        \\    .word __bss_end__
        \\
        \\.section .text
        \\.global eventHandler
        \\.global _start
        \\_start: 
        \\    b eventHandler //This is never exectued, but required for the linker to not optimize out the eventHandler function
    );
}
export var PD_eventHandler: *const fn (playdate: *pdapi.PlaydateAPI, event: pdapi.PDSystemEvent, arg: u32) callconv(.C) c_int linksection(".capi_handler") = main.eventHandler;
