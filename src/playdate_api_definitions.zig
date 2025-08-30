const std = @import("std");
const builtin = @import("builtin");

pub const PlaydateAPI = extern struct {
    system: *const PlaydateSys,
    file: *const PlaydateFile,
    graphics: *const PlaydateGraphics,
    sprite: *const PlaydateSprite,
    display: *const PlaydateDisplay,
    sound: *const PlaydateSound,
    lua: *const PlaydateLua,
    json: *const PlaydateJSON,
    scoreboards: *const PlaydateScoreboards,
    network: *const PlaydateNetwork,
};

/////////Zig Utility Functions///////////
pub fn is_compiling_for_playdate_hardware() bool {
    return builtin.os.tag == .freestanding and builtin.cpu.arch.isThumb();
}

////////Buttons//////////////
pub const PDButtons = c_int;
pub const BUTTON_LEFT = (1 << 0);
pub const BUTTON_RIGHT = (1 << 1);
pub const BUTTON_UP = (1 << 2);
pub const BUTTON_DOWN = (1 << 3);
pub const BUTTON_B = (1 << 4);
pub const BUTTON_A = (1 << 5);

///////////////System/////////////////////////
pub const PDMenuItem = opaque {};
pub const PDCallbackFunction = *const fn (userdata: ?*anyopaque) callconv(.c) c_int;
pub const PDMenuItemCallbackFunction = *const fn (userdata: ?*anyopaque) callconv(.c) void;
pub const PDButtonCallbackFunction = *const fn (
    button: PDButtons,
    down: c_int,
    when: u32,
    userdata: ?*anyopaque,
) callconv(.c) c_int;
pub const PDSystemEvent = enum(c_int) {
    EventInit,
    EventInitLua,
    EventLock,
    EventUnlock,
    EventPause,
    EventResume,
    EventTerminate,
    EventKeyPressed, // arg is keycode
    EventKeyReleased,
    EventLowPower,
};
pub const PDLanguage = enum(c_int) {
    PDLanguageEnglish,
    PDLanguageJapanese,
    PDLanguageUnknown,
};

pub const AccessRequestCallback = ?*const fn (allowed: bool, userdata: ?*anyopaque) callconv(.c) void;
pub const AccessReply = enum(c_int) {
    AccessAsk = 0,
    AccessDeny,
    AccessAllow,
};

pub const PDPeripherals = c_int;
pub const PERIPHERAL_NONE = 0;
pub const PERIPHERAL_ACCELEROMETER = (1 << 0);
// ...
pub const PERIPHERAL_ALL = 0xFFFF;

pub const PDStringEncoding = enum(c_int) {
    ASCIIEncoding,
    UTF8Encoding,
    @"16BitLEEncoding",
};

pub const PDDateTime = extern struct {
    year: u16,
    month: u8, // 1-12
    day: u8, // 1-31
    weekday: u8, // 1=monday-7=sunday
    hour: u8, // 0-23
    minute: u8,
    second: u8,
};

pub const PlaydateSys = extern struct {
    realloc: *const fn (ptr: ?*anyopaque, size: usize) callconv(.c) ?*anyopaque,
    formatString: *const fn (ret: ?*[*c]u8, fmt: ?[*:0]const u8, ...) callconv(.c) c_int,
    logToConsole: *const fn (fmt: ?[*:0]const u8, ...) callconv(.c) void,
    @"error": *const fn (fmt: ?[*:0]const u8, ...) callconv(.c) void,
    getLanguage: *const fn () callconv(.c) PDLanguage,
    getCurrentTimeMilliseconds: *const fn () callconv(.c) c_uint,
    getSecondsSinceEpoch: *const fn (milliseconds: ?*c_uint) callconv(.c) c_uint,
    drawFPS: *const fn (x: c_int, y: c_int) callconv(.c) void,

    setUpdateCallback: *const fn (update: ?PDCallbackFunction, userdata: ?*anyopaque) callconv(.c) void,
    getButtonState: *const fn (current: ?*PDButtons, pushed: ?*PDButtons, released: ?*PDButtons) callconv(.c) void,
    setPeripheralsEnabled: *const fn (mask: PDPeripherals) callconv(.c) void,
    getAccelerometer: *const fn (outx: ?*f32, outy: ?*f32, outz: ?*f32) callconv(.c) void,
    getCrankChange: *const fn () callconv(.c) f32,
    getCrankAngle: *const fn () callconv(.c) f32,
    isCrankDocked: *const fn () callconv(.c) c_int,
    setCrankSoundsDisabled: *const fn (flag: c_int) callconv(.c) c_int, // returns previous setting

    getFlipped: *const fn () callconv(.c) c_int,
    setAutoLockDisabled: *const fn (disable: c_int) callconv(.c) void,

    setMenuImage: *const fn (bitmap: ?*LCDBitmap, xOffset: c_int) callconv(.c) void,
    addMenuItem: *const fn (title: ?[*:0]const u8, callback: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.c) ?*PDMenuItem,
    addCheckmarkMenuItem: *const fn (title: ?[*:0]const u8, value: c_int, callback: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.c) ?*PDMenuItem,
    addOptionsMenuItem: *const fn (title: ?[*:0]const u8, optionTitles: [*c]?[*:0]const u8, optionsCount: c_int, f: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.c) ?*PDMenuItem,
    removeAllMenuItems: *const fn () callconv(.c) void,
    removeMenuItem: *const fn (menuItem: ?*PDMenuItem) callconv(.c) void,
    getMenuItemValue: *const fn (menuItem: ?*PDMenuItem) callconv(.c) c_int,
    setMenuItemValue: *const fn (menuItem: ?*PDMenuItem, value: c_int) callconv(.c) void,
    getMenuItemTitle: *const fn (menuItem: ?*PDMenuItem) callconv(.c) ?[*:0]const u8,
    setMenuItemTitle: *const fn (menuItem: ?*PDMenuItem, title: ?[*:0]const u8) callconv(.c) void,
    getMenuItemUserdata: *const fn (menuItem: ?*PDMenuItem) callconv(.c) ?*anyopaque,
    setMenuItemUserdata: *const fn (menuItem: ?*PDMenuItem, ud: ?*anyopaque) callconv(.c) void,

    getReduceFlashing: *const fn () callconv(.c) c_int,

    // 1.1
    getElapsedTime: *const fn () callconv(.c) f32,
    resetElapsedTime: *const fn () callconv(.c) void,

    // 1.4
    getBatteryPercentage: *const fn () callconv(.c) f32,
    getBatteryVoltage: *const fn () callconv(.c) f32,

    // 1.13
    getTimezoneOffset: *const fn () callconv(.c) i32,
    shouldDisplay24HourTime: *const fn () callconv(.c) c_int,
    convertEpochToDateTime: *const fn (epoch: u32, datetime: ?*PDDateTime) callconv(.c) void,
    convertDateTimeToEpoch: *const fn (datetime: ?*PDDateTime) callconv(.c) u32,

    //2.0
    clearICache: *const fn () callconv(.c) void,

    // 2.4
    setButtonCallback: *const fn (
        cb: ?PDButtonCallbackFunction,
        buttonud: ?*anyopaque,
        queuesize: c_int,
    ) callconv(.c) void,
    setSerialMessageCallback: *const fn (
        callback: *const fn (data: ?[*:0]const u8) callconv(.c) void,
    ) callconv(.c) void,
    vaFormatString: *const fn (
        outstr: [*c][*c]u8,
        fmt: ?[*:0]const u8,
        args: VaList,
    ) callconv(.c) c_int,
    parseString: *const fn (
        str: ?[*:0]const u8,
        format: ?[*:0]const u8,
        ...,
    ) callconv(.c) c_int,

    // ???
    delay: *const fn (milliseconds: u32) callconv(.c) void,

    // 2.7
    getServerTime: *const fn (callback: *const fn (time: ?[*:0]const u8, err: ?[*:0]const u8) callconv(.c) void) callconv(.c) void,
    restartGame: *const fn (launchargs: ?[*:0]const u8) callconv(.c) void,
    getLaunchArgs: *const fn (outpath: [*c][*:0]const u8) callconv(.c) ?[*:0]const u8,
    sendMirrorData: *const fn (command: u8, data: [*c]u8, len: c_int) callconv(.c) bool,

    //NOTE(Daniel Bokser): std.builtin.VaList is not available when targeting Playdate hardware,
    //      so we need to directly include it
    const VaList = if (is_compiling_for_playdate_hardware() or builtin.os.tag == .windows)
        @cImport({
            @cInclude("stdarg.h");
        }).va_list
    else
        //NOTE(Daniel Bokser):
        //  We must use std.builtin.VaList when building for the Linux simulator.
        //  Using stdarg.h results in a compiler error otherwise.
        std.builtin.VaList;
};

////////LCD and Graphics///////////////////////
pub const LCD_COLUMNS = 400;
pub const LCD_ROWS = 240;
pub const LCD_ROWSIZE = 52;
pub const LCDBitmap = opaque {};
pub const LCDVideoPlayer = opaque {};
pub const LCDStreamPlayer = opaque {};
pub const PlaydateVideo = extern struct {
    loadVideo: *const fn (?[*:0]const u8) callconv(.c) ?*LCDVideoPlayer,
    freePlayer: *const fn (?*LCDVideoPlayer) callconv(.c) void,
    setContext: *const fn (?*LCDVideoPlayer, ?*LCDBitmap) callconv(.c) c_int,
    useScreenContext: *const fn (?*LCDVideoPlayer) callconv(.c) void,
    renderFrame: *const fn (?*LCDVideoPlayer, c_int) callconv(.c) c_int,
    getError: *const fn (?*LCDVideoPlayer) callconv(.c) ?[*:0]const u8,
    getInfo: *const fn (?*LCDVideoPlayer, [*c]c_int, [*c]c_int, [*c]f32, [*c]c_int, [*c]c_int) callconv(.c) void,
    getContext: *const fn (?*LCDVideoPlayer) callconv(.c) ?*LCDBitmap,
};

pub const LCDPattern = [16]u8;
pub const LCDColor = usize; //Pointer to LCDPattern or a LCDSolidColor value
pub const LCDSolidColor = enum(c_int) {
    ColorBlack,
    ColorWhite,
    ColorClear,
    ColorXOR,
};
pub const LCDBitmapDrawMode = enum(c_int) {
    DrawModeCopy,
    DrawModeWhiteTransparent,
    DrawModeBlackTransparent,
    DrawModeFillWhite,
    DrawModeFillBlack,
    DrawModeXOR,
    DrawModeNXOR,
    DrawModeInverted,
};
pub const LCDLineCapStyle = enum(c_int) {
    LineCapStyleButt,
    LineCapStyleSquare,
    LineCapStyleRound,
};

pub const LCDFontLanguage = enum(c_int) {
    LCDFontLanguageEnglish,
    LCDFontLanguageJapanese,
    LCDFontLanguageUnknown,
};

pub const LCDBitmapFlip = enum(c_int) {
    BitmapUnflipped,
    BitmapFlippedX,
    BitmapFlippedY,
    BitmapFlippedXY,
};

pub const LCDPolygonFillRule = enum(c_int) {
    PolygonFillNonZero,
    PolygonFillEvenOdd,
};

pub const PDTextWrappingMode = enum(c_int) {
    WrapClip,
    WrapCharacter,
    WrapWord,
};

pub const PDTextAlignment = enum(c_int) {
    AlignTextLeft,
    AlignTextCenter,
    AlignTextRight,
};

pub const LCDTileMap = opaque {};
pub const LCDBitmapTable = opaque {};
pub const LCDFont = opaque {};
pub const LCDFontPage = opaque {};
pub const LCDFontGlyph = opaque {};
pub const LCDFontData = opaque {};
pub const LCDRect = extern struct {
    left: c_int,
    right: c_int,
    top: c_int,
    bottom: c_int,
};

pub const PlaydateVideostream = extern struct {
    newPlayer: *const fn () callconv(.c) ?*LCDStreamPlayer,
    freePlayer: *const fn (p: ?*LCDStreamPlayer) callconv(.c) void,

    setBufferSize: *const fn (p: ?*LCDStreamPlayer, video: c_int, audio: c_int) callconv(.c) void,

    setFile: *const fn (p: ?*LCDStreamPlayer, file: ?*SDFile) callconv(.c) void,

    setHTTPConnection: *const fn (p: ?*LCDStreamPlayer, conn: ?*HTTPConnection) callconv(.c) void,

    getFilePlayer: *const fn (p: ?*LCDStreamPlayer) callconv(.c) ?*FilePlayer,

    getVideoPlayer: *const fn (p: ?*LCDStreamPlayer) callconv(.c) ?*LCDVideoPlayer,

    // returns true if it drew a frame, else false
    update: *const fn (p: ?*LCDStreamPlayer) callconv(.c) bool,

    getBufferedFrameCount: *const fn (p: ?*LCDStreamPlayer) callconv(.c) c_int,

    //     uint32_t (*getBytesRead)(LCDStreamPlayer* p);
    getBytesRead: *const fn (p: ?*LCDStreamPlayer) callconv(.c) u32,

    // 3.0
    setTCPConnection: *const fn (p: ?*LCDStreamPlayer, conn: ?*TCPConnection) callconv(.c) void,
};

pub const PlaydateTilemap = extern struct {
    newTilemap: *const fn () callconv(.c) ?*LCDTileMap,
    freeTilemap: *const fn (m: ?*LCDTileMap) callconv(.c) void,

    setImageTable: *const fn (m: ?*LCDTileMap, table: ?*LCDBitmapTable) callconv(.c) void,
    getImageTable: *const fn (m: ?*LCDTileMap) callconv(.c) ?*LCDBitmapTable,

    setSize: *const fn (m: ?*LCDTileMap, tilesWide: c_int, tilesHigh: c_int) callconv(.c) void,
    getSize: *const fn (m: ?*LCDTileMap, tilesWide: ?*c_int, tilesHigh: ?*c_int) callconv(.c) void,
    getPixelSize: *const fn (m: ?*LCDTileMap, outWidth: ?*u32, outHeight: ?*u32) callconv(.c) void,

    setTiles: *const fn (m: ?*LCDTileMap, indexes: [*c]u16, count: c_int, rowwidth: c_int) callconv(.c) void,

    setTileAtPosition: *const fn (m: ?*LCDTileMap, x: c_int, y: c_int, idx: u16) callconv(.c) void,
    getTileAtPosition: *const fn (m: ?*LCDTileMap, x: c_int, y: c_int) callconv(.c) c_int,

    drawAtPoint: *const fn (m: ?*LCDTileMap, x: f32, y: f32) callconv(.c) void,
};

pub const PlaydateGraphics = extern struct {
    video: *const PlaydateVideo,
    // Drawing Functions
    clear: *const fn (color: LCDColor) callconv(.c) void,
    setBackgroundColor: *const fn (color: LCDSolidColor) callconv(.c) void,
    setStencil: *const fn (stencil: ?*LCDBitmap) callconv(.c) void, // deprecated in favor of setStencilImage, which adds a "tile" flag
    setDrawMode: *const fn (mode: LCDBitmapDrawMode) callconv(.c) void,
    setDrawOffset: *const fn (dx: c_int, dy: c_int) callconv(.c) void,
    setClipRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) callconv(.c) void,
    clearClipRect: *const fn () callconv(.c) void,
    setLineCapStyle: *const fn (endCapStyle: LCDLineCapStyle) callconv(.c) void,
    setFont: *const fn (font: ?*LCDFont) callconv(.c) void,
    setTextTracking: *const fn (tracking: c_int) callconv(.c) void,
    pushContext: *const fn (target: ?*LCDBitmap) callconv(.c) void,
    popContext: *const fn () callconv(.c) void,

    drawBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, flip: LCDBitmapFlip) callconv(.c) void,
    tileBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, width: c_int, height: c_int, flip: LCDBitmapFlip) callconv(.c) void,
    drawLine: *const fn (x1: c_int, y1: c_int, x2: c_int, y2: c_int, width: c_int, color: LCDColor) callconv(.c) void,
    fillTriangle: *const fn (x1: c_int, y1: c_int, x2: c_int, y2: c_int, x3: c_int, y3: c_int, color: LCDColor) callconv(.c) void,
    drawRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, color: LCDColor) callconv(.c) void,
    fillRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, color: LCDColor) callconv(.c) void,
    drawEllipse: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, lineWidth: c_int, startAngle: f32, endAngle: f32, color: LCDColor) callconv(.c) void,
    fillEllipse: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, startAngle: f32, endAngle: f32, color: LCDColor) callconv(.c) void,
    drawScaledBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, xscale: f32, yscale: f32) callconv(.c) void,
    drawText: *const fn (text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, x: c_int, y: c_int) callconv(.c) c_int,

    // LCDBitmap
    newBitmap: *const fn (width: c_int, height: c_int, color: LCDColor) callconv(.c) ?*LCDBitmap,
    freeBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.c) void,
    loadBitmap: *const fn (path: ?[*:0]const u8, outerr: ?*?[*:0]const u8) callconv(.c) ?*LCDBitmap,
    copyBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.c) ?*LCDBitmap,
    loadIntoBitmap: *const fn (path: ?[*:0]const u8, bitmap: ?*LCDBitmap, outerr: ?*?[*:0]const u8) callconv(.c) void,
    getBitmapData: *const fn (bitmap: ?*LCDBitmap, width: ?*c_int, height: ?*c_int, rowbytes: ?*c_int, mask: ?*[*c]u8, data: ?*[*c]u8) callconv(.c) void,
    clearBitmap: *const fn (bitmap: ?*LCDBitmap, bgcolor: LCDColor) callconv(.c) void,
    rotatedBitmap: *const fn (bitmap: ?*LCDBitmap, rotation: f32, xscale: f32, yscale: f32, allocedSize: ?*c_int) callconv(.c) ?*LCDBitmap,

    // LCDBitmapTable
    newBitmapTable: *const fn (count: c_int, width: c_int, height: c_int) callconv(.c) ?*LCDBitmapTable,
    freeBitmapTable: *const fn (table: ?*LCDBitmapTable) callconv(.c) void,
    loadBitmapTable: *const fn (path: ?[*:0]const u8, outerr: ?*?[*:0]const u8) callconv(.c) ?*LCDBitmapTable,
    loadIntoBitmapTable: *const fn (path: ?[*:0]const u8, table: ?*LCDBitmapTable, outerr: ?*?[*:0]const u8) callconv(.c) void,
    getTableBitmap: *const fn (table: ?*LCDBitmapTable, idx: c_int) callconv(.c) ?*LCDBitmap,

    // LCDFont
    loadFont: *const fn (path: ?[*:0]const u8, outErr: ?*?[*:0]const u8) callconv(.c) ?*LCDFont,
    getFontPage: *const fn (font: ?*LCDFont, c: u32) callconv(.c) ?*LCDFontPage,
    getPageGlyph: *const fn (page: ?*LCDFontPage, c: u32, bitmap: ?**LCDBitmap, advance: ?*c_int) callconv(.c) ?*LCDFontGlyph,
    getGlyphKerning: *const fn (glyph: ?*LCDFontGlyph, glyphcode: u32, nextcode: u32) callconv(.c) c_int,
    getTextWidth: *const fn (font: ?*LCDFont, text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, tracking: c_int) callconv(.c) c_int,

    // raw framebuffer access
    getFrame: *const fn () callconv(.c) [*c]u8, // row stride = LCD_ROWSIZE
    getDisplayFrame: *const fn () callconv(.c) [*c]u8, // row stride = LCD_ROWSIZE
    getDebugBitmap: *const fn () callconv(.c) ?*LCDBitmap, // valid in simulator only, function is null on device
    copyFrameBufferBitmap: *const fn () callconv(.c) ?*LCDBitmap,
    markUpdatedRows: *const fn (start: c_int, end: c_int) callconv(.c) void,
    display: *const fn () callconv(.c) void,

    // misc util.
    setColorToPattern: *const fn (color: ?*LCDColor, bitmap: ?*LCDBitmap, x: c_int, y: c_int) callconv(.c) void,
    checkMaskCollision: *const fn (bitmap1: ?*LCDBitmap, x1: c_int, y1: c_int, flip1: LCDBitmapFlip, bitmap2: ?*LCDBitmap, x2: c_int, y2: c_int, flip2: LCDBitmapFlip, rect: LCDRect) callconv(.c) c_int,

    // 1.1
    setScreenClipRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) callconv(.c) void,

    // 1.1.1
    fillPolygon: *const fn (nPoints: c_int, coords: [*c]c_int, color: LCDColor, fillRule: LCDPolygonFillRule) callconv(.c) void,
    getFontHeight: *const fn (font: ?*LCDFont) callconv(.c) u8,

    // 1.7
    getDisplayBufferBitmap: *const fn () callconv(.c) ?*LCDBitmap,
    drawRotatedBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, rotation: f32, centerx: f32, centery: f32, xscale: f32, yscale: f32) callconv(.c) void,
    setTextLeading: *const fn (lineHeightAdustment: c_int) callconv(.c) void,

    // 1.8
    setBitmapMask: *const fn (bitmap: ?*LCDBitmap, mask: ?*LCDBitmap) callconv(.c) c_int,
    getBitmapMask: *const fn (bitmap: ?*LCDBitmap) callconv(.c) ?*LCDBitmap,

    // 1.10
    setStencilImage: *const fn (stencil: ?*LCDBitmap, tile: c_int) callconv(.c) void,

    // 1.12
    makeFontFromData: *const fn (data: ?*LCDFontData, wide: c_int) callconv(.c) *LCDFont,

    // 2.1
    getTextTracking: *const fn () callconv(.c) c_int,

    // 2.5
    setPixel: *const fn (x: c_int, y: c_int, c: LCDColor) callconv(.c) void,
    getBitmapPixel: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int) callconv(.c) LCDSolidColor,
    getBitmapTableInfo: *const fn (table: ?*LCDBitmapTable, count: ?*c_int, width: ?*c_int) callconv(.c) void,

    // 2.6
    drawTextInRect: *const fn (text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, x: c_int, y: c_int, width: c_int, height: c_int, wrap: PDTextWrappingMode, @"align": PDTextAlignment) callconv(.c) void,

    // 2.7
    getTextHeightForMaxWidth: *const fn (font: ?*LCDFont, text: ?[*:0]const u8, len: usize, maxwidth: c_int, encoding: PDStringEncoding, wrap: PDTextWrappingMode, tracking: c_int, extraLeading: c_int) callconv(.c) c_int,
    drawRoundRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, radius: c_int, lineWidth: c_int, color: LCDColor) callconv(.c) void,
    fillRoundRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, radius: c_int, color: LCDColor) callconv(.c) void,

    // 3.0
    tilemap: *const PlaydateTilemap,
    videostream: *const PlaydateVideostream,
};
pub const PlaydateDisplay = struct {
    getWidth: *const fn () callconv(.c) c_int,
    getHeight: *const fn () callconv(.c) c_int,

    setRefreshRate: *const fn (rate: f32) callconv(.c) void,

    setInverted: *const fn (flag: c_int) callconv(.c) void,
    setScale: *const fn (s: c_uint) callconv(.c) void,
    setMosaic: *const fn (x: c_uint, y: c_uint) callconv(.c) void,
    setFlipped: *const fn (x: c_int, y: c_int) callconv(.c) void,
    setOffset: *const fn (x: c_int, y: c_int) callconv(.c) void,

    // 2.7
    getRefreshRate: *const fn () callconv(.c) f32,
    getFPS: *const fn () callconv(.c) f32,
};

//////File System/////
pub const SDFile = opaque {};

pub const FileOptions = c_int;
pub const FILE_READ = (1 << 0);
pub const FILE_READ_DATA = (1 << 1);
pub const FILE_WRITE = (1 << 2);
pub const FILE_APPEND = (2 << 2);

pub const SEEK_SET = 0;
pub const SEEK_CUR = 1;
pub const SEEK_END = 2;

pub const FileStat = extern struct {
    isdir: c_int,
    size: c_uint,
    m_year: c_int,
    m_month: c_int,
    m_day: c_int,
    m_hour: c_int,
    m_minute: c_int,
    m_second: c_int,
};

pub const PlaydateFile = extern struct {
    geterr: *const fn () callconv(.c) ?[*:0]const u8,

    listfiles: *const fn (
        path: ?[*:0]const u8,
        callback: *const fn (path: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.c) void,
        userdata: ?*anyopaque,
        showhidden: c_int,
    ) callconv(.c) c_int,
    stat: *const fn (path: ?[*:0]const u8, stat: ?*FileStat) callconv(.c) c_int,
    mkdir: *const fn (path: ?[*:0]const u8) callconv(.c) c_int,
    unlink: *const fn (name: ?[*:0]const u8, recursive: c_int) callconv(.c) c_int,
    rename: *const fn (from: ?[*:0]const u8, to: ?[*:0]const u8) callconv(.c) c_int,

    open: *const fn (name: ?[*:0]const u8, mode: FileOptions) callconv(.c) ?*SDFile,
    close: *const fn (file: ?*SDFile) callconv(.c) c_int,
    read: *const fn (file: ?*SDFile, buf: ?*anyopaque, len: c_uint) callconv(.c) c_int,
    write: *const fn (file: ?*SDFile, buf: ?*const anyopaque, len: c_uint) callconv(.c) c_int,
    flush: *const fn (file: ?*SDFile) callconv(.c) c_int,
    tell: *const fn (file: ?*SDFile) callconv(.c) c_int,
    seek: *const fn (file: ?*SDFile, pos: c_int, whence: c_int) callconv(.c) c_int,
};

/////////Audio//////////////
pub const MicSource = enum(c_int) {
    kMicInputAutodetect = 0,
    kMicInputInternal = 1,
    kMicInputHeadset = 2,
};
pub const PlaydateSound = extern struct {
    channel: *const PlaydateSoundChannel,
    fileplayer: *const PlaydateSoundFileplayer,
    sample: *const PlaydateSoundSample,
    sampleplayer: *const PlaydateSoundSampleplayer,
    synth: *const PlaydateSoundSynth,
    sequence: *const PlaydateSoundSequence,
    effect: *const PlaydateSoundEffect,
    lfo: *const PlaydateSoundLFO,
    envelope: *const PlaydateSoundEnvelope,
    source: *const PlaydateSoundSource,
    controlsignal: *const PlaydateControlSignal,
    track: *const PlaydateSoundTrack,
    instrument: *const PlaydateSoundInstrument,

    getCurrentTime: *const fn () callconv(.c) u32,
    addSource: *const fn (callback: AudioSourceFunction, context: ?*anyopaque, stereo: c_int) callconv(.c) ?*SoundSource,

    getDefaultChannel: *const fn () callconv(.c) ?*SoundChannel,

    addChannel: *const fn (channel: ?*SoundChannel) callconv(.c) void,
    removeChannel: *const fn (channel: ?*SoundChannel) callconv(.c) void,

    setMicCallback: *const fn (callback: RecordCallback, context: ?*anyopaque, source: MicSource) callconv(.c) void,
    getHeadphoneState: *const fn (
        headphone: ?*c_int,
        headsetmic: ?*c_int,
        changeCallback: ?*const fn (headphone: c_int, mic: c_int) callconv(.c) void,
    ) callconv(.c) void,
    setOutputsActive: *const fn (headphone: c_int, mic: c_int) callconv(.c) void,

    // 1.5
    removeSource: *const fn (?*SoundSource) callconv(.c) void,

    // 1.12
    signal: *const PlaydateSoundSignal,

    // 2.2
    getError: *const fn () callconv(.c) ?[*:0]const u8,
};

//data is mono
pub const RecordCallback = *const fn (context: ?*anyopaque, buffer: [*c]i16, length: c_int) callconv(.c) c_int;
// len is # of samples in each buffer, function should return 1 if it produced output
pub const AudioSourceFunction = *const fn (context: ?*anyopaque, left: [*c]i16, right: [*c]i16, len: c_int) callconv(.c) c_int;
pub const SndCallbackProc = *const fn (c: ?*SoundSource, userdata: ?*anyopaque) callconv(.c) void;

pub const SoundChannel = opaque {};
pub const SoundSource = opaque {};
pub const SoundEffect = opaque {};
pub const PDSynthSignalValue = opaque {};

pub const PlaydateSoundChannel = extern struct {
    newChannel: *const fn () callconv(.c) ?*SoundChannel,
    freeChannel: *const fn (channel: ?*SoundChannel) callconv(.c) void,
    addSource: *const fn (channel: ?*SoundChannel, source: ?*SoundSource) callconv(.c) c_int,
    removeSource: *const fn (channel: ?*SoundChannel, source: ?*SoundSource) callconv(.c) c_int,
    addCallbackSource: *const fn (?*SoundChannel, AudioSourceFunction, ?*anyopaque, c_int) callconv(.c) ?*SoundSource,
    addEffect: *const fn (channel: ?*SoundChannel, effect: ?*SoundEffect) callconv(.c) void,
    removeEffect: *const fn (channel: ?*SoundChannel, effect: ?*SoundEffect) callconv(.c) void,
    setVolume: *const fn (channel: ?*SoundChannel, f32) callconv(.c) void,
    getVolume: *const fn (channel: ?*SoundChannel) callconv(.c) f32,
    setVolumeModulator: *const fn (channel: ?*SoundChannel, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getVolumeModulator: *const fn (channel: ?*SoundChannel) callconv(.c) ?*PDSynthSignalValue,
    setPan: *const fn (channel: ?*SoundChannel, pan: f32) callconv(.c) void,
    setPanModulator: *const fn (channel: ?*SoundChannel, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getPanModulator: *const fn (channel: ?*SoundChannel) callconv(.c) ?*PDSynthSignalValue,
    getDryLevelSignal: *const fn (channe: ?*SoundChannel) callconv(.c) ?*PDSynthSignalValue,
    getWetLevelSignal: *const fn (channel: ?*SoundChannel) callconv(.c) ?*PDSynthSignalValue,
};

pub const FilePlayer = SoundSource;
pub const PlaydateSoundFileplayer = extern struct {
    newPlayer: *const fn () callconv(.c) ?*FilePlayer,
    freePlayer: *const fn (player: ?*FilePlayer) callconv(.c) void,
    loadIntoPlayer: *const fn (player: ?*FilePlayer, path: ?[*:0]const u8) callconv(.c) c_int,
    setBufferLength: *const fn (player: ?*FilePlayer, bufferLen: f32) callconv(.c) void,
    play: *const fn (player: ?*FilePlayer, repeat: c_int) callconv(.c) c_int,
    isPlaying: *const fn (player: ?*FilePlayer) callconv(.c) c_int,
    pause: *const fn (player: ?*FilePlayer) callconv(.c) void,
    stop: *const fn (player: ?*FilePlayer) callconv(.c) void,
    setVolume: *const fn (player: ?*FilePlayer, left: f32, right: f32) callconv(.c) void,
    getVolume: *const fn (player: ?*FilePlayer, left: ?*f32, right: ?*f32) callconv(.c) void,
    getLength: *const fn (player: ?*FilePlayer) callconv(.c) f32,
    setOffset: *const fn (player: ?*FilePlayer, offset: f32) callconv(.c) void,
    setRate: *const fn (player: ?*FilePlayer, rate: f32) callconv(.c) void,
    setLoopRange: *const fn (player: ?*FilePlayer, start: f32, end: f32) callconv(.c) void,
    didUnderrun: *const fn (player: ?*FilePlayer) callconv(.c) c_int,
    setFinishCallback: *const fn (
        player: ?*FilePlayer,
        callback: ?SndCallbackProc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    setLoopCallback: *const fn (
        player: ?*FilePlayer,
        callback: ?SndCallbackProc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    getOffset: *const fn (player: ?*FilePlayer) callconv(.c) f32,
    getRate: *const fn (player: ?*FilePlayer) callconv(.c) f32,
    setStopOnUnderrun: *const fn (player: ?*FilePlayer, flag: c_int) callconv(.c) void,
    fadeVolume: *const fn (
        player: ?*FilePlayer,
        left: f32,
        right: f32,
        len: i32,
        finishCallback: ?SndCallbackProc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    setMP3StreamSource: *const fn (
        player: ?*FilePlayer,
        dataSource: *const fn (data: [*c]u8, bytes: c_int, userdata: ?*anyopaque) callconv(.c) c_int,
        userdata: ?*anyopaque,
        bufferLen: f32,
    ) callconv(.c) void,
};

pub const AudioSample = opaque {};
pub const SamplePlayer = SoundSource;

pub const SoundFormat = enum(c_uint) {
    kSound8bitMono = 0,
    kSound8bitStereo = 1,
    kSound16bitMono = 2,
    kSound16bitStereo = 3,
    kSoundADPCMMono = 4,
    kSoundADPCMStereo = 5,
};
pub inline fn SoundFormatIsStereo(f: SoundFormat) bool {
    return @intFromEnum(f) & 1;
}
pub inline fn SoundFormatIs16bit(f: SoundFormat) bool {
    return switch (f) {
        .kSound16bitMono,
        .kSound16bitStereo,
        .kSoundADPCMMono,
        .kSoundADPCMStereo,
        => true,
        else => false,
    };
}
pub inline fn SoundFormat_bytesPerFrame(fmt: SoundFormat) u32 {
    return (if (SoundFormatIsStereo(fmt)) 2 else 1) *
        (if (SoundFormatIs16bit(fmt)) 2 else 1);
}

pub const PlaydateSoundSample = extern struct {
    newSampleBuffer: *const fn (byteCount: c_int) callconv(.c) ?*AudioSample,
    loadIntoSample: *const fn (sample: ?*AudioSample, path: ?[*:0]const u8) callconv(.c) c_int,
    load: *const fn (path: ?[*:0]const u8) callconv(.c) ?*AudioSample,
    newSampleFromData: *const fn (data: [*c]u8, format: SoundFormat, sampleRate: u32, byteCount: c_int, shouldFreeData: c_int) callconv(.c) ?*AudioSample,
    getData: *const fn (sample: ?*AudioSample, data: ?*[*c]u8, format: [*c]SoundFormat, sampleRate: ?*u32, byteLength: ?*u32) callconv(.c) void,
    freeSample: *const fn (sample: ?*AudioSample) callconv(.c) void,
    getLength: *const fn (sample: ?*AudioSample) callconv(.c) f32,

    // 2.4
    decompress: *const fn (sample: ?*AudioSample) callconv(.c) c_int,
};

pub const PlaydateSoundSampleplayer = extern struct {
    newPlayer: *const fn () callconv(.c) ?*SamplePlayer,
    freePlayer: *const fn (?*SamplePlayer) callconv(.c) void,
    setSample: *const fn (player: ?*SamplePlayer, sample: ?*AudioSample) callconv(.c) void,
    play: *const fn (player: ?*SamplePlayer, repeat: c_int, rate: f32) callconv(.c) c_int,
    isPlaying: *const fn (player: ?*SamplePlayer) callconv(.c) c_int,
    stop: *const fn (player: ?*SamplePlayer) callconv(.c) void,
    setVolume: *const fn (player: ?*SamplePlayer, left: f32, right: f32) callconv(.c) void,
    getVolume: *const fn (player: ?*SamplePlayer, left: ?*f32, right: ?*f32) callconv(.c) void,
    getLength: *const fn (player: ?*SamplePlayer) callconv(.c) f32,
    setOffset: *const fn (player: ?*SamplePlayer, offset: f32) callconv(.c) void,
    setRate: *const fn (player: ?*SamplePlayer, rate: f32) callconv(.c) void,
    setPlayRange: *const fn (player: ?*SamplePlayer, start: c_int, end: c_int) callconv(.c) void,
    setFinishCallback: *const fn (
        player: ?*SamplePlayer,
        callback: ?SndCallbackProc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    setLoopCallback: *const fn (
        player: ?*SamplePlayer,
        callback: ?SndCallbackProc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    getOffset: *const fn (player: ?*SamplePlayer) callconv(.c) f32,
    getRate: *const fn (player: ?*SamplePlayer) callconv(.c) f32,
    setPaused: *const fn (player: ?*SamplePlayer, flag: c_int) callconv(.c) void,
};

pub const PDSynth = SoundSource;
pub const SoundWaveform = enum(c_uint) {
    kWaveformSquare = 0,
    kWaveformTriangle = 1,
    kWaveformSine = 2,
    kWaveformNoise = 3,
    kWaveformSawtooth = 4,
    kWaveformPOPhase = 5,
    kWaveformPODigital = 6,
    kWaveformPOVosim = 7,
};
pub const NOTE_C4 = 60.0;
pub const MIDINote = f32;
pub inline fn pd_noteToFrequency(n: MIDINote) f32 {
    return 440 * std.math.pow(f32, 2, (n - 69) / 12.0);
}
pub inline fn pd_frequencyToNote(f: f32) MIDINote {
    return 12 * std.math.log(f32, 2, f) - 36.376316562;
}

// generator render callback
// samples are in Q8.24 format. left is either the left channel or the single mono channel,
// right is non-NULL only if the stereo flag was set in the setGenerator() call.
// nsamples is at most 256 but may be shorter
// rate is Q0.32 per-frame phase step, drate is per-frame rate step (i.e., do rate += drate every frame)
// return value is the number of sample frames rendered
pub const SynthRenderFunc = *const fn (userdata: ?*anyopaque, left: [*c]i32, right: [*c]i32, nsamples: c_int, rate: u32, drate: i32) callconv(.c) c_int;

// generator event callbacks

// len == -1 if indefinite
pub const SynthNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, velocity: f32, len: f32) callconv(.c) void;

pub const SynthReleaseFunc = *const fn (userdata: ?*anyopaque, stop: c_int) callconv(.c) void;
pub const SynthSetParameterFunc = *const fn (userdata: ?*anyopaque, parameter: c_int, value: f32) callconv(.c) c_int;
pub const SynthDeallocFunc = *const fn (userdata: ?*anyopaque) callconv(.c) void;
pub const SynthCopyUserdata = *const fn (userdata: ?*anyopaque) callconv(.c) ?*anyopaque;

pub const PlaydateSoundSynth = extern struct {
    newSynth: *const fn () callconv(.c) ?*PDSynth,
    freeSynth: *const fn (synth: ?*PDSynth) callconv(.c) void,

    setWaveform: *const fn (synth: ?*PDSynth, wave: SoundWaveform) callconv(.c) void,
    setGenerator_deprecated: *const fn (
        synth: ?*PDSynth,
        stereo: c_int,
        render: SynthRenderFunc,
        note_on: SynthNoteOnFunc,
        release: SynthReleaseFunc,
        set_param: SynthSetParameterFunc,
        dealloc: SynthDeallocFunc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    setSample: *const fn (
        synth: ?*PDSynth,
        sample: ?*AudioSample,
        sustain_start: u32,
        sustain_end: u32,
    ) callconv(.c) void,

    setAttackTime: *const fn (synth: ?*PDSynth, attack: f32) callconv(.c) void,
    setDecayTime: *const fn (synth: ?*PDSynth, decay: f32) callconv(.c) void,
    setSustainLevel: *const fn (synth: ?*PDSynth, sustain: f32) callconv(.c) void,
    setReleaseTime: *const fn (synth: ?*PDSynth, release: f32) callconv(.c) void,

    setTranspose: *const fn (synth: ?*PDSynth, half_steps: f32) callconv(.c) void,

    setFrequencyModulator: *const fn (synth: ?*PDSynth, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getFrequencyModulator: *const fn (synth: ?*PDSynth) callconv(.c) ?*PDSynthSignalValue,
    setAmplitudeModulator: *const fn (synth: ?*PDSynth, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getAmplitudeModulator: *const fn (synth: ?*PDSynth) callconv(.c) ?*PDSynthSignalValue,

    getParameterCount: *const fn (synth: ?*PDSynth) callconv(.c) c_int,
    setParameter: *const fn (synth: ?*PDSynth, parameter: c_int, value: f32) callconv(.c) c_int,
    setParameterModulator: *const fn (synth: ?*PDSynth, parameter: c_int, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getParameterModulator: *const fn (synth: ?*PDSynth, parameter: c_int) callconv(.c) ?*PDSynthSignalValue,

    playNote: *const fn (synth: ?*PDSynth, freq: f32, vel: f32, len: f32, when: u32) callconv(.c) void,
    playMIDINote: *const fn (synth: ?*PDSynth, note: MIDINote, vel: f32, len: f32, when: u32) callconv(.c) void,
    noteOff: *const fn (synth: ?*PDSynth, when: u32) callconv(.c) void,
    stop: *const fn (synth: ?*PDSynth) callconv(.c) void,

    setVolume: *const fn (synth: ?*PDSynth, left: f32, right: f32) callconv(.c) void,
    getVolume: *const fn (synth: ?*PDSynth, left: ?*f32, right: ?*f32) callconv(.c) void,

    isPlaying: *const fn (synth: ?*PDSynth) callconv(.c) c_int,

    // 1.13
    getEnvelope: *const fn (synth: ?*PDSynth) callconv(.c) ?*PDSynthEnvelope, // synth keeps ownership--don't free this!

    // 2.2
    setWavetable: *const fn (synth: ?*PDSynth, sample: ?*AudioSample, log2size: c_int, columns: c_int, rows: c_int) callconv(.c) c_int,

    // 2.4
    setGenerator: *const fn (
        synth: ?*PDSynth,
        stereo: c_int,
        render: SynthRenderFunc,
        noteOn: SynthNoteOnFunc,
        release: SynthReleaseFunc,
        setparam: SynthSetParameterFunc,
        dealloc: SynthDeallocFunc,
        copyUserdata: SynthCopyUserdata,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
    copy: *const fn (synth: ?*PDSynth) callconv(.c) ?*PDSynth,

    // 2.6
    clearEnvelope: *const fn (synth: ?*PDSynth) callconv(.c) void,
};

pub const SequenceTrack = opaque {};
pub const SoundSequence = opaque {};
pub const SequenceFinishedCallback = *const fn (seq: ?*SoundSequence, userdata: ?*anyopaque) callconv(.c) void;

pub const PlaydateSoundSequence = extern struct {
    newSequence: *const fn () callconv(.c) ?*SoundSequence,
    freeSequence: *const fn (sequence: ?*SoundSequence) callconv(.c) void,

    loadMidiFile: *const fn (seq: ?*SoundSequence, path: ?[*:0]const u8) callconv(.c) c_int,
    getTime: *const fn (seq: ?*SoundSequence) callconv(.c) u32,
    setTime: *const fn (seq: ?*SoundSequence, time: u32) callconv(.c) void,
    setLoops: *const fn (seq: ?*SoundSequence, loopstart: c_int, loopend: c_int, loops: c_int) callconv(.c) void,
    getTempo_deprecated: *const fn (seq: ?*SoundSequence) callconv(.c) c_int,
    setTempo: *const fn (seq: ?*SoundSequence, stepsPerSecond: c_int) callconv(.c) void,
    getTrackCount: *const fn (seq: ?*SoundSequence) callconv(.c) c_int,
    addTrack: *const fn (seq: ?*SoundSequence) callconv(.c) ?*SequenceTrack,
    getTrackAtIndex: *const fn (seq: ?*SoundSequence, track: c_uint) callconv(.c) ?*SequenceTrack,
    setTrackAtIndex: *const fn (seq: ?*SoundSequence, ?*SequenceTrack, idx: c_uint) callconv(.c) void,
    allNotesOff: *const fn (seq: ?*SoundSequence) callconv(.c) void,

    // 1.1
    isPlaying: *const fn (seq: ?*SoundSequence) callconv(.c) c_int,
    getLength: *const fn (seq: ?*SoundSequence) callconv(.c) u32,
    play: *const fn (seq: ?*SoundSequence, finishCallback: SequenceFinishedCallback, userdata: ?*anyopaque) callconv(.c) void,
    stop: *const fn (seq: ?*SoundSequence) callconv(.c) void,
    getCurrentStep: *const fn (seq: ?*SoundSequence, timeOffset: ?*c_int) callconv(.c) c_int,
    setCurrentStep: *const fn (seq: ?*SoundSequence, step: c_int, timeOffset: c_int, playNotes: c_int) callconv(.c) void,

    // 2.5
    getTempo: *const fn (seq: ?*SoundSequence) callconv(.c) f32,
};

pub const EffectProc = *const fn (e: ?*SoundEffect, left: [*c]i32, right: [*c]i32, nsamples: c_int, bufactive: c_int) callconv(.c) c_int;

pub const PlaydateSoundEffect = extern struct {
    newEffect: *const fn (proc: ?*const EffectProc, userdata: ?*anyopaque) callconv(.c) ?*SoundEffect,
    freeEffect: *const fn (effect: ?*SoundEffect) callconv(.c) void,

    setMix: *const fn (effect: ?*SoundEffect, level: f32) callconv(.c) void,
    setMixModulator: *const fn (effect: ?*SoundEffect, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getMixModulator: *const fn (effect: ?*SoundEffect) callconv(.c) ?*PDSynthSignalValue,

    setUserdata: *const fn (effect: ?*SoundEffect, userdata: ?*anyopaque) callconv(.c) void,
    getUserdata: *const fn (effect: ?*SoundEffect) callconv(.c) ?*anyopaque,

    twopolefilter: *const PlaydateSoundEffectTwopolefilter,
    onepolefilter: *const PlaydateSoundEffectOnepolefilter,
    bitcrusher: *const PlaydateSoundEffectBitcrusher,
    ringmodulator: *const PlaydateSoundEffectRingmodulator,
    delayline: *const PlaydateSoundEffectDelayline,
    overdrive: *const PlaydateSoundEffectOverdrive,
};
pub const LFOType = enum(c_uint) {
    kLFOTypeSquare = 0,
    kLFOTypeTriangle = 1,
    kLFOTypeSine = 2,
    kLFOTypeSampleAndHold = 3,
    kLFOTypeSawtoothUp = 4,
    kLFOTypeSawtoothDown = 5,
    kLFOTypeArpeggiator = 6,
    kLFOTypeFunction = 7,
};
pub const PDSynthLFO = opaque {};
pub const PlaydateSoundLFO = extern struct {
    newLFO: *const fn (LFOType) callconv(.c) ?*PDSynthLFO,
    freeLFO: *const fn (lfo: ?*PDSynthLFO) callconv(.c) void,

    setType: *const fn (lfo: ?*PDSynthLFO, type: LFOType) callconv(.c) void,
    setRate: *const fn (lfo: ?*PDSynthLFO, rate: f32) callconv(.c) void,
    setPhase: *const fn (lfo: ?*PDSynthLFO, phase: f32) callconv(.c) void,
    setCenter: *const fn (lfo: ?*PDSynthLFO, center: f32) callconv(.c) void,
    setDepth: *const fn (lfo: ?*PDSynthLFO, depth: f32) callconv(.c) void,
    setArpeggiation: *const fn (lfo: ?*PDSynthLFO, nSteps: c_int, steps: [*c]f32) callconv(.c) void,
    setFunction: *const fn (
        lfo: ?*PDSynthLFO,
        lfoFunc: *const fn (lfo: ?*PDSynthLFO, userdata: ?*anyopaque) callconv(.c) f32,
        userdata: ?*anyopaque,
        interpolate: c_int,
    ) callconv(.c) void,
    setDelay: *const fn (lfo: ?*PDSynthLFO, holdoff: f32, ramptime: f32) callconv(.c) void,
    setRetrigger: *const fn (lfo: ?*PDSynthLFO, flag: c_int) callconv(.c) void,

    getValue: *const fn (lfo: ?*PDSynthLFO) callconv(.c) f32,

    // 1.10
    setGlobal: *const fn (lfo: ?*PDSynthLFO, global: c_int) callconv(.c) void,
};

pub const PDSynthEnvelope = opaque {};
pub const PlaydateSoundEnvelope = extern struct {
    newEnvelope: *const fn (attack: f32, decay: f32, sustain: f32, release: f32) callconv(.c) ?*PDSynthEnvelope,
    freeEnvelope: *const fn (env: ?*PDSynthEnvelope) callconv(.c) void,

    setAttack: *const fn (env: ?*PDSynthEnvelope, attack: f32) callconv(.c) void,
    setDecay: *const fn (env: ?*PDSynthEnvelope, decay: f32) callconv(.c) void,
    setSustain: *const fn (env: ?*PDSynthEnvelope, sustain: f32) callconv(.c) void,
    setRelease: *const fn (env: ?*PDSynthEnvelope, release: f32) callconv(.c) void,

    setLegato: *const fn (env: ?*PDSynthEnvelope, flag: c_int) callconv(.c) void,
    setRetrigger: *const fn (env: ?*PDSynthEnvelope, flag: c_int) callconv(.c) void,

    getValue: *const fn (env: ?*PDSynthEnvelope) callconv(.c) f32,

    // 1.13
    setCurvature: *const fn (env: ?*PDSynthEnvelope, amount: f32) callconv(.c) void,
    setVelocitySensitivity: *const fn (env: ?*PDSynthEnvelope, velsens: f32) callconv(.c) void,
    setRateScaling: *const fn (env: ?*PDSynthEnvelope, scaling: f32, start: MIDINote, end: MIDINote) callconv(.c) void,
};

pub const PlaydateSoundSource = extern struct {
    setVolume: *const fn (c: ?*SoundSource, lvol: f32, rvol: f32) callconv(.c) void,
    getVolume: *const fn (c: ?*SoundSource, outl: ?*f32, outr: ?*f32) callconv(.c) void,
    isPlaying: *const fn (c: ?*SoundSource) callconv(.c) c_int,
    setFinishCallback: *const fn (
        c: ?*SoundSource,
        callback: SndCallbackProc,
        userdata: ?*anyopaque,
    ) callconv(.c) void,
};

pub const ControlSignal = opaque {};
pub const PlaydateControlSignal = extern struct {
    newSignal: *const fn () callconv(.c) ?*ControlSignal,
    freeSignal: *const fn (signal: ?*ControlSignal) callconv(.c) void,
    clearEvents: *const fn (control: ?*ControlSignal) callconv(.c) void,
    addEvent: *const fn (control: ?*ControlSignal, step: c_int, value: f32, c_int) callconv(.c) void,
    removeEvent: *const fn (control: ?*ControlSignal, step: c_int) callconv(.c) void,
    getMIDIControllerNumber: *const fn (control: ?*ControlSignal) callconv(.c) c_int,
};

pub const PlaydateSoundTrack = extern struct {
    newTrack: *const fn () callconv(.c) ?*SequenceTrack,
    freeTrack: *const fn (track: ?*SequenceTrack) callconv(.c) void,

    setInstrument: *const fn (track: ?*SequenceTrack, inst: ?*PDSynthInstrument) callconv(.c) void,
    getInstrument: *const fn (track: ?*SequenceTrack) callconv(.c) ?*PDSynthInstrument,

    addNoteEvent: *const fn (track: ?*SequenceTrack, step: u32, len: u32, note: MIDINote, velocity: f32) callconv(.c) void,
    removeNoteEvent: *const fn (track: ?*SequenceTrack, step: u32, note: MIDINote) callconv(.c) void,
    clearNotes: *const fn (track: ?*SequenceTrack) callconv(.c) void,

    getControlSignalCount: *const fn (track: ?*SequenceTrack) callconv(.c) c_int,
    getControlSignal: *const fn (track: ?*SequenceTrack, idx: c_int) callconv(.c) ?*ControlSignal,
    clearControlEvents: *const fn (track: ?*SequenceTrack) callconv(.c) void,

    getPolyphony: *const fn (track: ?*SequenceTrack) callconv(.c) c_int,
    activeVoiceCount: *const fn (track: ?*SequenceTrack) callconv(.c) c_int,

    setMuted: *const fn (track: ?*SequenceTrack, mute: c_int) callconv(.c) void,

    // 1.1
    getLength: *const fn (track: ?*SequenceTrack) callconv(.c) u32,
    getIndexForStep: *const fn (track: ?*SequenceTrack, step: u32) callconv(.c) c_int,
    getNoteAtIndex: *const fn (track: ?*SequenceTrack, index: c_int, outSteo: ?*u32, outLen: ?*u32, outeNote: ?*MIDINote, outVelocity: ?*f32) callconv(.c) c_int,

    //1.10
    getSignalForController: *const fn (track: ?*SequenceTrack, controller: c_int, create: c_int) callconv(.c) ?*ControlSignal,
};

pub const PDSynthInstrument = SoundSource;
pub const PlaydateSoundInstrument = extern struct {
    newInstrument: *const fn () callconv(.c) ?*PDSynthInstrument,
    freeInstrument: *const fn (inst: ?*PDSynthInstrument) callconv(.c) void,
    addVoice: *const fn (inst: ?*PDSynthInstrument, synth: ?*PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: f32) callconv(.c) c_int,
    playNote: *const fn (inst: ?*PDSynthInstrument, frequency: f32, vel: f32, len: f32, when: u32) callconv(.c) ?*PDSynth,
    playMIDINote: *const fn (inst: ?*PDSynthInstrument, note: MIDINote, vel: f32, len: f32, when: u32) callconv(.c) ?*PDSynth,
    setPitchBend: *const fn (inst: ?*PDSynthInstrument, bend: f32) callconv(.c) void,
    setPitchBendRange: *const fn (inst: ?*PDSynthInstrument, halfSteps: f32) callconv(.c) void,
    setTranspose: *const fn (inst: ?*PDSynthInstrument, halfSteps: f32) callconv(.c) void,
    noteOff: *const fn (inst: ?*PDSynthInstrument, note: MIDINote, when: u32) callconv(.c) void,
    allNotesOff: *const fn (inst: ?*PDSynthInstrument, when: u32) callconv(.c) void,
    setVolume: *const fn (inst: ?*PDSynthInstrument, left: f32, right: f32) callconv(.c) void,
    getVolume: *const fn (inst: ?*PDSynthInstrument, left: ?*f32, right: ?*f32) callconv(.c) void,
    activeVoiceCount: *const fn (inst: ?*PDSynthInstrument) callconv(.c) c_int,
};

pub const PDSynthSignal = opaque {};
pub const SignalStepFunc = *const fn (userdata: ?*anyopaque, ioframes: [*c]c_int, ifval: ?*f32) callconv(.c) f32;
// len = -1 for indefinite
pub const SignalNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, vel: f32, len: f32) callconv(.c) void;
// ended = 0 for note release, = 1 when note stops playing
pub const SignalNoteOffFunc = *const fn (userdata: ?*anyopaque, stopped: c_int, offset: c_int) callconv(.c) void;
pub const SignalDeallocFunc = *const fn (userdata: ?*anyopaque) callconv(.c) void;
pub const PlaydateSoundSignal = struct {
    newSignal: *const fn (step: SignalStepFunc, noteOn: SignalNoteOnFunc, noteOff: SignalNoteOffFunc, dealloc: SignalDeallocFunc, userdata: ?*anyopaque) callconv(.c) ?*PDSynthSignal,
    freeSignal: *const fn (signal: ?*PDSynthSignal) callconv(.c) void,
    getValue: *const fn (signal: ?*PDSynthSignal) callconv(.c) f32,
    setValueScale: *const fn (signal: ?*PDSynthSignal, scale: f32) callconv(.c) void,
    setValueOffset: *const fn (signal: ?*PDSynthSignal, offset: f32) callconv(.c) void,
};

// EFFECTS

// A SoundEffect processes the output of a channel's SoundSources

pub const TwoPoleFilter = SoundEffect;
pub const TwoPoleFilterType = enum(c_int) {
    FilterTypeLowPass,
    FilterTypeHighPass,
    FilterTypeBandPass,
    FilterTypeNotch,
    FilterTypePEQ,
    FilterTypeLowShelf,
    FilterTypeHighShelf,
};
pub const PlaydateSoundEffectTwopolefilter = extern struct {
    newFilter: *const fn () callconv(.c) ?*TwoPoleFilter,
    freeFilter: *const fn (filter: ?*TwoPoleFilter) callconv(.c) void,
    setType: *const fn (filter: ?*TwoPoleFilter, type: TwoPoleFilterType) callconv(.c) void,
    setFrequency: *const fn (filter: ?*TwoPoleFilter, frequency: f32) callconv(.c) void,
    setFrequencyModulator: *const fn (filter: ?*TwoPoleFilter, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getFrequencyModulator: *const fn (filter: ?*TwoPoleFilter) callconv(.c) ?*PDSynthSignalValue,
    setGain: *const fn (filter: ?*TwoPoleFilter, f32) callconv(.c) void,
    setResonance: *const fn (filter: ?*TwoPoleFilter, f32) callconv(.c) void,
    setResonanceModulator: *const fn (filter: ?*TwoPoleFilter, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getResonanceModulator: *const fn (filter: ?*TwoPoleFilter) callconv(.c) ?*PDSynthSignalValue,
};

pub const OnePoleFilter = SoundEffect;
pub const PlaydateSoundEffectOnepolefilter = extern struct {
    newFilter: *const fn () callconv(.c) ?*OnePoleFilter,
    freeFilter: *const fn (filter: ?*OnePoleFilter) callconv(.c) void,
    setParameter: *const fn (filter: ?*OnePoleFilter, parameter: f32) callconv(.c) void,
    setParameterModulator: *const fn (filter: ?*OnePoleFilter, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getParameterModulator: *const fn (filter: ?*OnePoleFilter) callconv(.c) ?*PDSynthSignalValue,
};

pub const BitCrusher = SoundEffect;
pub const PlaydateSoundEffectBitcrusher = extern struct {
    newBitCrusher: *const fn () callconv(.c) ?*BitCrusher,
    freeBitCrusher: *const fn (filter: ?*BitCrusher) callconv(.c) void,
    setAmount: *const fn (filter: ?*BitCrusher, amount: f32) callconv(.c) void,
    setAmountModulator: *const fn (filter: ?*BitCrusher, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getAmountModulator: *const fn (filter: ?*BitCrusher) callconv(.c) ?*PDSynthSignalValue,
    setUndersampling: *const fn (filter: ?*BitCrusher, undersampling: f32) callconv(.c) void,
    setUndersampleModulator: *const fn (filter: ?*BitCrusher, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getUndersampleModulator: *const fn (filter: ?*BitCrusher) callconv(.c) ?*PDSynthSignalValue,
};

pub const RingModulator = SoundEffect;
pub const PlaydateSoundEffectRingmodulator = extern struct {
    newRingmod: *const fn () callconv(.c) ?*RingModulator,
    freeRingmod: *const fn (filter: ?*RingModulator) callconv(.c) void,
    setFrequency: *const fn (filter: ?*RingModulator, frequency: f32) callconv(.c) void,
    setFrequencyModulator: *const fn (filter: ?*RingModulator, signal: ?*PDSynthSignalValue) callconv(.c) void,
    getFrequencyModulator: *const fn (filter: ?*RingModulator) callconv(.c) ?*PDSynthSignalValue,
};

pub const DelayLine = SoundEffect;
pub const DelayLineTap = SoundSource;
pub const PlaydateSoundEffectDelayline = extern struct {
    newDelayLine: *const fn (length: c_int, stereo: c_int) callconv(.c) ?*DelayLine,
    freeDelayLine: *const fn (filter: ?*DelayLine) callconv(.c) void,
    setLength: *const fn (filter: ?*DelayLine, frames: c_int) callconv(.c) void,
    setFeedback: *const fn (filter: ?*DelayLine, fb: f32) callconv(.c) void,
    addTap: *const fn (filter: ?*DelayLine, delay: c_int) callconv(.c) ?*DelayLineTap,

    // note that DelayLineTap is a SoundSource, not a SoundEffect
    freeTap: *const fn (tap: ?*DelayLineTap) callconv(.c) void,
    setTapDelay: *const fn (t: ?*DelayLineTap, frames: c_int) callconv(.c) void,
    setTapDelayModulator: *const fn (t: ?*DelayLineTap, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getTapDelayModulator: *const fn (t: ?*DelayLineTap) callconv(.c) ?*PDSynthSignalValue,
    setTapChannelsFlipped: *const fn (t: ?*DelayLineTap, flip: c_int) callconv(.c) void,
};

pub const Overdrive = SoundEffect;
pub const PlaydateSoundEffectOverdrive = extern struct {
    newOverdrive: *const fn () callconv(.c) ?*Overdrive,
    freeOverdrive: *const fn (filter: ?*Overdrive) callconv(.c) void,
    setGain: *const fn (o: ?*Overdrive, gain: f32) callconv(.c) void,
    setLimit: *const fn (o: ?*Overdrive, limit: f32) callconv(.c) void,
    setLimitModulator: *const fn (o: ?*Overdrive, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getLimitModulator: *const fn (o: ?*Overdrive) callconv(.c) ?*PDSynthSignalValue,
    setOffset: *const fn (o: ?*Overdrive, offset: f32) callconv(.c) void,
    setOffsetModulator: *const fn (o: ?*Overdrive, mod: ?*PDSynthSignalValue) callconv(.c) void,
    getOffsetModulator: *const fn (o: ?*Overdrive) callconv(.c) ?*PDSynthSignalValue,
};

//////Sprite/////
pub const SpriteCollisionResponseType = enum(c_int) {
    CollisionTypeSlide,
    CollisionTypeFreeze,
    CollisionTypeOverlap,
    CollisionTypeBounce,
};
pub const PDRect = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub fn PDRectMake(x: f32, y: f32, width: f32, height: f32) callconv(.c) PDRect {
    return .{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
}

pub const CollisionPoint = extern struct {
    x: f32,
    y: f32,
};
pub const CollisionVector = extern struct {
    x: c_int,
    y: c_int,
};

pub const SpriteCollisionInfo = extern struct {
    sprite: ?*LCDSprite, // The sprite being moved
    other: ?*LCDSprite, // The sprite being moved
    responseType: SpriteCollisionResponseType, // The result of collisionResponse
    overlaps: u8, // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
    ti: f32, // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
    move: CollisionPoint, // The difference between the original coordinates and the actual ones when the collision happened
    normal: CollisionVector, // The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
    touch: CollisionPoint, // The coordinates where the sprite started touching other
    spriteRect: PDRect, // The rectangle the sprite occupied when the touch happened
    otherRect: PDRect, // The rectangle the sprite being collided with occupied when the touch happened
};

pub const SpriteQueryInfo = extern struct {
    sprite: ?*LCDSprite, // The sprite being intersected by the segment
    // ti1 and ti2 are numbers between 0 and 1 which indicate how far from the starting point of the line segment the collision happened
    ti1: f32, // entry point
    ti2: f32, // exit point
    entryPoint: CollisionPoint, // The coordinates of the first intersection between sprite and the line segment
    exitPoint: CollisionPoint, // The coordinates of the second intersection between sprite and the line segment
};

pub const LCDSprite = opaque {};
pub const CWCollisionInfo = opaque {};
pub const CWItemInfo = opaque {};

pub const LCDSpriteDrawFunction = ?*const fn (sprite: ?*LCDSprite, bounds: PDRect, drawrect: PDRect) callconv(.c) void;
pub const LCDSpriteUpdateFunction = ?*const fn (sprite: ?*LCDSprite) callconv(.c) void;
pub const LCDSpriteCollisionFilterProc = ?*const fn (sprite: ?*LCDSprite, other: ?*LCDSprite) callconv(.c) SpriteCollisionResponseType;

pub const PlaydateSprite = extern struct {
    setAlwaysRedraw: *const fn (flag: c_int) callconv(.c) void,
    addDirtyRect: *const fn (dirtyRect: LCDRect) callconv(.c) void,
    drawSprites: *const fn () callconv(.c) void,
    updateAndDrawSprites: *const fn () callconv(.c) void,

    newSprite: *const fn () callconv(.c) ?*LCDSprite,
    freeSprite: *const fn (sprite: ?*LCDSprite) callconv(.c) void,
    copy: *const fn (sprite: ?*LCDSprite) callconv(.c) ?*LCDSprite,

    addSprite: *const fn (sprite: ?*LCDSprite) callconv(.c) void,
    removeSprite: *const fn (sprite: ?*LCDSprite) callconv(.c) void,
    removeSprites: *const fn (sprite: [*c]?*LCDSprite, count: c_int) callconv(.c) void,
    removeAllSprites: *const fn () callconv(.c) void,
    getSpriteCount: *const fn () callconv(.c) c_int,

    setBounds: *const fn (sprite: ?*LCDSprite, bounds: PDRect) callconv(.c) void,
    getBounds: *const fn (sprite: ?*LCDSprite) callconv(.c) PDRect,
    moveTo: *const fn (sprite: ?*LCDSprite, x: f32, y: f32) callconv(.c) void,
    moveBy: *const fn (sprite: ?*LCDSprite, dx: f32, dy: f32) callconv(.c) void,

    setImage: *const fn (sprite: ?*LCDSprite, image: ?*LCDBitmap, flip: LCDBitmapFlip) callconv(.c) void,
    getImage: *const fn (sprite: ?*LCDSprite) callconv(.c) ?*LCDBitmap,
    setSize: *const fn (s: ?*LCDSprite, width: f32, height: f32) callconv(.c) void,
    setZIndex: *const fn (s: ?*LCDSprite, zIndex: i16) callconv(.c) void,
    getZIndex: *const fn (sprite: ?*LCDSprite) callconv(.c) i16,

    setDrawMode: *const fn (sprite: ?*LCDSprite, mode: LCDBitmapDrawMode) callconv(.c) LCDBitmapDrawMode,
    setImageFlip: *const fn (sprite: ?*LCDSprite, flip: LCDBitmapFlip) callconv(.c) void,
    getImageFlip: *const fn (sprite: ?*LCDSprite) callconv(.c) LCDBitmapFlip,
    setStencil: *const fn (sprite: ?*LCDSprite, mode: ?*LCDBitmap) callconv(.c) void, // deprecated in favor of setStencilImage()

    setClipRect: *const fn (sprite: ?*LCDSprite, clipRect: LCDRect) callconv(.c) void,
    clearClipRect: *const fn (sprite: ?*LCDSprite) callconv(.c) void,
    setClipRectsInRange: *const fn (clipRect: LCDRect, startZ: c_int, endZ: c_int) callconv(.c) void,
    clearClipRectsInRange: *const fn (startZ: c_int, endZ: c_int) callconv(.c) void,

    setUpdatesEnabled: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.c) void,
    updatesEnabled: *const fn (sprite: ?*LCDSprite) callconv(.c) c_int,
    setCollisionsEnabled: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.c) void,
    collisionsEnabled: *const fn (sprite: ?*LCDSprite) callconv(.c) c_int,
    setVisible: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.c) void,
    isVisible: *const fn (sprite: ?*LCDSprite) callconv(.c) c_int,
    setOpaque: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.c) void,
    markDirty: *const fn (sprite: ?*LCDSprite) callconv(.c) void,

    setTag: *const fn (sprite: ?*LCDSprite, tag: u8) callconv(.c) void,
    getTag: *const fn (sprite: ?*LCDSprite) callconv(.c) u8,

    setIgnoresDrawOffset: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.c) void,

    setUpdateFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteUpdateFunction) callconv(.c) void,
    setDrawFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteDrawFunction) callconv(.c) void,

    getPosition: *const fn (s: ?*LCDSprite, x: ?*f32, y: ?*f32) callconv(.c) void,

    // Collisions
    resetCollisionWorld: *const fn () callconv(.c) void,

    setCollideRect: *const fn (sprite: ?*LCDSprite, collideRect: PDRect) callconv(.c) void,
    getCollideRect: *const fn (sprite: ?*LCDSprite) callconv(.c) PDRect,
    clearCollideRect: *const fn (sprite: ?*LCDSprite) callconv(.c) void,

    // caller is responsible for freeing the returned array for all collision methods
    setCollisionResponseFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteCollisionFilterProc) callconv(.c) void,
    checkCollisions: *const fn (sprite: ?*LCDSprite, goalX: f32, goalY: f32, actualX: ?*f32, actualY: ?*f32, len: ?*c_int) callconv(.c) [*c]SpriteCollisionInfo, // access results using const info = &results[i];
    moveWithCollisions: *const fn (sprite: ?*LCDSprite, goalX: f32, goalY: f32, actualX: ?*f32, actualY: ?*f32, len: ?*c_int) callconv(.c) [*c]SpriteCollisionInfo,
    querySpritesAtPoint: *const fn (x: f32, y: f32, len: ?*c_int) callconv(.c) [*c]?*LCDSprite,
    querySpritesInRect: *const fn (x: f32, y: f32, width: f32, height: f32, len: ?*c_int) callconv(.c) [*c]?*LCDSprite,
    querySpritesAlongLine: *const fn (x1: f32, y1: f32, x2: f32, y2: f32, len: ?*c_int) callconv(.c) [*c]?*LCDSprite,
    querySpriteInfoAlongLine: *const fn (x1: f32, y1: f32, x2: f32, y2: f32, len: ?*c_int) callconv(.c) [*c]SpriteQueryInfo, // access results using const info = &results[i];
    overlappingSprites: *const fn (sprite: ?*LCDSprite, len: ?*c_int) callconv(.c) [*c]?*LCDSprite,
    allOverlappingSprites: *const fn (len: ?*c_int) callconv(.c) [*c]?*LCDSprite,

    // added in 1.7
    setStencilPattern: *const fn (sprite: ?*LCDSprite, pattern: [*c]u8) callconv(.c) void, //pattern is 8 bytes
    clearStencil: *const fn (sprite: ?*LCDSprite) callconv(.c) void,

    setUserdata: *const fn (sprite: ?*LCDSprite, userdata: ?*anyopaque) callconv(.c) void,
    getUserdata: *const fn (sprite: ?*LCDSprite) callconv(.c) ?*anyopaque,

    // added in 1.10
    setStencilImage: *const fn (sprite: ?*LCDSprite, stencil: ?*LCDBitmap, tile: c_int) callconv(.c) void,

    // 2.1
    setCenter: *const fn (s: ?*LCDSprite, x: f32, y: f32) callconv(.c) void,
    getCenter: *const fn (s: ?*LCDSprite, x: ?*f32, y: ?*f32) callconv(.c) void,

    // 2.7
    setTilemap: *const fn (s: ?*LCDSprite, tilemap: ?*LCDTileMap) callconv(.c) void,
    getTilemap: *const fn (s: ?*LCDSprite) callconv(.c) ?*LCDTileMap,
};

////////Lua///////
pub const LuaState = ?*anyopaque;
pub const LuaCFunction = ?*const fn (state: ?*LuaState) callconv(.c) c_int;
pub const LuaUDObject = opaque {};

//literal value
pub const LValType = enum(c_int) {
    Int = 0,
    Float = 1,
    Str = 2,
};
pub const LuaReg = extern struct {
    name: ?[*:0]const u8,
    func: LuaCFunction,
};
pub const LuaType = enum(c_int) {
    TypeNil = 0,
    TypeBool = 1,
    TypeInt = 2,
    TypeFloat = 3,
    TypeString = 4,
    TypeTable = 5,
    TypeFunction = 6,
    TypeThread = 7,
    TypeObject = 8,
};
pub const LuaVal = extern struct {
    name: ?[*:0]const u8,
    type: LValType,
    v: extern union {
        intval: c_uint,
        floatval: f32,
        strval: ?[*:0]const u8,
    },
};
pub const PlaydateLua = extern struct {
    // these two return 1 on success, else 0 with an error message in outErr
    addFunction: *const fn (f: LuaCFunction, name: ?[*:0]const u8, outErr: ?*?[*:0]const u8) callconv(.c) c_int,
    registerClass: *const fn (name: ?[*:0]const u8, reg: ?*const LuaReg, vals: [*c]const LuaVal, isstatic: c_int, outErr: ?*?[*:0]const u8) callconv(.c) c_int,

    pushFunction: *const fn (f: LuaCFunction) callconv(.c) void,
    indexMetatable: *const fn () callconv(.c) c_int,

    stop: *const fn () callconv(.c) void,
    start: *const fn () callconv(.c) void,

    // stack operations
    getArgCount: *const fn () callconv(.c) c_int,
    getArgType: *const fn (pos: c_int, outClass: ?*?[*:0]const u8) callconv(.c) LuaType,

    argIsNil: *const fn (pos: c_int) callconv(.c) c_int,
    getArgBool: *const fn (pos: c_int) callconv(.c) c_int,
    getArgInt: *const fn (pos: c_int) callconv(.c) c_int,
    getArgFloat: *const fn (pos: c_int) callconv(.c) f32,
    getArgString: *const fn (pos: c_int) callconv(.c) ?[*:0]const u8,
    getArgBytes: *const fn (pos: c_int, outlen: ?*usize) callconv(.c) [*c]const u8,
    getArgObject: *const fn (pos: c_int, type: ?*i8, ?*?*LuaUDObject) callconv(.c) ?*anyopaque,

    getBitmap: *const fn (c_int) callconv(.c) ?*LCDBitmap,
    getSprite: *const fn (c_int) callconv(.c) ?*LCDSprite,

    // for returning values back to Lua
    pushNil: *const fn () callconv(.c) void,
    pushBool: *const fn (val: c_int) callconv(.c) void,
    pushInt: *const fn (val: c_int) callconv(.c) void,
    pushFloat: *const fn (val: f32) callconv(.c) void,
    pushString: *const fn (str: ?[*:0]const u8) callconv(.c) void,
    pushBytes: *const fn (str: [*c]const u8, len: usize) callconv(.c) void,
    pushBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.c) void,
    pushSprite: *const fn (sprite: ?*LCDSprite) callconv(.c) void,

    pushObject: *const fn (obj: ?*anyopaque, type: ?*i8, nValues: c_int) callconv(.c) ?*LuaUDObject,
    retainObject: *const fn (obj: ?*LuaUDObject) callconv(.c) ?*LuaUDObject,
    releaseObject: *const fn (obj: ?*LuaUDObject) callconv(.c) void,

    setObjectValue: *const fn (obj: ?*LuaUDObject, slot: c_int) callconv(.c) void,
    getObjectValue: *const fn (obj: ?*LuaUDObject, slot: c_int) callconv(.c) c_int,

    // calling lua from C has some overhead. use sparingly!
    callFunction_deprecated: *const fn (name: ?[*:0]const u8, nargs: c_int) callconv(.c) void,
    callFunction: *const fn (name: ?[*:0]const u8, nargs: c_int, outerr: ?*?[*:0]const u8) callconv(.c) c_int,
};

///////JSON///////
pub const JSONValueType = enum(c_int) {
    JSONNull = 0,
    JSONTrue = 1,
    JSONFalse = 2,
    JSONInteger = 3,
    JSONFloat = 4,
    JSONString = 5,
    JSONArray = 6,
    JSONTable = 7,
};
pub const JSONValue = extern struct {
    type: u8,
    data: extern union {
        intval: c_int,
        floatval: f32,
        stringval: [*c]u8,
        arrayval: ?*anyopaque,
        tableval: ?*anyopaque,
    },
};
pub inline fn json_intValue(value: JSONValue) c_int {
    switch (@intFromEnum(value.type)) {
        .JSONInteger => return value.data.intval,
        .JSONFloat => return @intFromFloat(value.data.floatval),
        .JSONString => return std.fmt.parseInt(c_int, std.mem.span(value.data.stringval), 10) catch 0,
        .JSONTrue => return 1,
        else => return 0,
    }
}
pub inline fn json_floatValue(value: JSONValue) f32 {
    switch (@as(JSONValueType, @enumFromInt(value.type))) {
        .JSONInteger => return @floatFromInt(value.data.intval),
        .JSONFloat => return value.data.floatval,
        .JSONString => return 0,
        .JSONTrue => 1.0,
        else => return 0.0,
    }
}
pub inline fn json_boolValue(value: JSONValue) c_int {
    return if (@as(JSONValueType, @enumFromInt(value.type)) == .JSONString)
        @intFromBool(value.data.stringval[0] != 0)
    else
        json_intValue(value);
}
pub inline fn json_stringValue(value: JSONValue) [*c]u8 {
    return if (@as(JSONValueType, @enumFromInt(value.type)) == .JSONString)
        value.data.stringval
    else
        null;
}

// decoder

pub const JSONDecoder = extern struct {
    decodeError: *const fn (decoder: ?*JSONDecoder, @"error": ?[*:0]const u8, linenum: c_int) callconv(.c) void,

    // the following functions are each optional
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: ?[*:0]const u8, type: JSONValueType) callconv(.c) void,
    shouldDecodeTableValueForKey: ?*const fn (decoder: ?*JSONDecoder, key: ?[*:0]const u8) callconv(.c) c_int,
    didDecodeTableValue: ?*const fn (decoder: ?*JSONDecoder, key: ?[*:0]const u8, value: JSONValue) callconv(.c) void,
    shouldDecodeArrayValueAtIndex: ?*const fn (decoder: ?*JSONDecoder, pos: c_int) callconv(.c) c_int,
    didDecodeArrayValue: ?*const fn (decoder: ?*JSONDecoder, pos: c_int, value: JSONValue) callconv(.c) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: ?[*:0]const u8, type: JSONValueType) callconv(.c) ?*anyopaque,

    userdata: ?*anyopaque,
    returnString: c_int, // when set, the decoder skips parsing and returns the current subtree as a string
    path: ?[*:0]const u8, // updated during parsing, reflects current position in tree
};

// convenience functions for setting up a table-only or array-only decoder

pub inline fn json_setTableDecode(
    decoder: ?*JSONDecoder,
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: ?[*:0]const u8, type: JSONValueType) callconv(.c) void,
    didDecodeTableValue: ?*const fn (decoder: ?*JSONDecoder, key: ?[*:0]const u8, value: JSONValue) callconv(.c) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: ?[*:0]const u8, name: JSONValueType) callconv(.c) ?*anyopaque,
) void {
    decoder.?.didDecodeTableValue = didDecodeTableValue;
    decoder.?.didDecodeArrayValue = null;
    decoder.?.willDecodeSublist = willDecodeSublist;
    decoder.?.didDecodeSublist = didDecodeSublist;
}

pub inline fn json_setArrayDecode(
    decoder: ?*JSONDecoder,
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: ?[*:0]const u8, type: JSONValueType) callconv(.c) void,
    didDecodeArrayValue: ?*const fn (decoder: ?*JSONDecoder, pos: c_int, value: JSONValue) callconv(.c) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: ?[*:0]const u8, type: JSONValueType) callconv(.c) ?*anyopaque,
) void {
    decoder.?.didDecodeTableValue = null;
    decoder.?.didDecodeArrayValue = didDecodeArrayValue;
    decoder.?.willDecodeSublist = willDecodeSublist;
    decoder.?.didDecodeSublist = didDecodeSublist;
}

pub const JSONReader = extern struct {
    read: *const fn (userdata: ?*anyopaque, buf: [*c]u8, bufsize: c_int) callconv(.c) c_int,
    userdata: ?*anyopaque,
};
pub const writeFunc = *const fn (userdata: ?*anyopaque, str: [*c]const u8, len: c_int) callconv(.c) void;

pub const JSONEncoder = extern struct {
    writeStringFunc: writeFunc,
    userdata: ?*anyopaque,

    state: u32, //this is pretty, startedTable, startedArray and depth bitfields combined

    startArray: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    addArrayMember: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    endArray: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    startTable: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    addTableMember: *const fn (encoder: ?*JSONEncoder, name: [*c]const u8, len: c_int) callconv(.c) void,
    endTable: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    writeNull: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    writeFalse: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    writeTrue: *const fn (encoder: ?*JSONEncoder) callconv(.c) void,
    writeInt: *const fn (encoder: ?*JSONEncoder, num: c_int) callconv(.c) void,
    writeDouble: *const fn (encoder: ?*JSONEncoder, num: f64) callconv(.c) void,
    writeString: *const fn (encoder: ?*JSONEncoder, str: [*c]const u8, len: c_int) callconv(.c) void,
};

pub const PlaydateJSON = extern struct {
    initEncoder: *const fn (encoder: ?*JSONEncoder, write: writeFunc, userdata: ?*anyopaque, pretty: c_int) callconv(.c) void,

    decode: *const fn (functions: ?*JSONDecoder, reader: JSONReader, outval: ?*JSONValue) callconv(.c) c_int,
    decodeString: *const fn (functions: ?*JSONDecoder, jsonString: ?[*:0]const u8, outval: ?*JSONValue) callconv(.c) c_int,
};

///////Scoreboards///////////
pub const PDScore = extern struct {
    rank: u32,
    value: u32,
    player: [*c]u8,
};
pub const PDScoresList = extern struct {
    boardID: [*c]u8,
    count: c_uint,
    lastUpdated: u32,
    playerIncluded: c_int,
    limit: c_uint,
    scores: [*c]PDScore,
};
pub const PDBoard = extern struct {
    boardID: [*c]u8,
    name: [*c]u8,
};
pub const PDBoardsList = extern struct {
    count: c_uint,
    lastUpdated: u32,
    boards: [*c]PDBoard,
};
pub const AddScoreCallback = ?*const fn (score: ?*PDScore, errorMessage: ?[*:0]const u8) callconv(.c) void;
pub const PersonalBestCallback = ?*const fn (score: ?*PDScore, errorMessage: ?[*:0]const u8) callconv(.c) void;
pub const BoardsListCallback = ?*const fn (boards: ?*PDBoardsList, errorMessage: ?[*:0]const u8) callconv(.c) void;
pub const ScoresCallback = ?*const fn (scores: ?*PDScoresList, errorMessage: ?[*:0]const u8) callconv(.c) void;

pub const PlaydateScoreboards = extern struct {
    addScore: *const fn (boardId: ?[*:0]const u8, value: u32, callback: AddScoreCallback) callconv(.c) c_int,
    getPersonalBest: *const fn (boardId: ?[*:0]const u8, callback: PersonalBestCallback) callconv(.c) c_int,
    freeScore: *const fn (score: ?*PDScore) callconv(.c) void,

    getScoreboards: *const fn (callback: BoardsListCallback) callconv(.c) c_int,
    freeBoardsList: *const fn (boards: ?*PDBoardsList) callconv(.c) void,

    getScores: *const fn (boardId: ?[*:0]const u8, callback: ScoresCallback) callconv(.c) c_int,
    freeScoresList: *const fn (scores: ?*PDScoresList) callconv(.c) void,
};

///////Network///////////
pub const HTTPConnection = opaque {};
pub const TCPConnection = opaque {};

pub const PDNetErr = enum(c_int) {
    NET_OK = 0,
    NET_NO_DEVICE = -1,
    NET_BUSY = -2,
    NET_WRITE_ERROR = -3,
    NET_WRITE_BUSY = -4,
    NET_WRITE_TIMEOUT = -5,
    NET_READ_ERROR = -6,
    NET_READ_BUSY = -7,
    NET_READ_TIMEOUT = -8,
    NET_READ_OVERFLOW = -9,
    NET_FRAME_ERROR = -10,
    NET_BAD_RESPONSE = -11,
    NET_ERROR_RESPONSE = -12,
    NET_RESET_TIMEOUT = -13,
    NET_BUFFER_TOO_SMALL = -14,
    NET_UNEXPECTED_RESPONSE = -15,
    NET_NOT_CONNECTED_TO_AP = -16,
    NET_NOT_IMPLEMENTED = -17,
    NET_CONNECTION_CLOSED = -18,
};

pub const WifiStatus = enum(c_int) {
    WifiNotConnected = 0, //< Not connected to an AP
    WifiConnected, //< Device is connected to an AP
    WifiNotAvailable, //< A connection has been attempted and no configured AP was available
};

pub const HTTPConnectionCallback = ?*const fn (connection: ?*HTTPConnection) callconv(.c) void;
pub const HTTPHeaderCallback = ?*const fn (conn: ?*HTTPConnection, key: ?[*:0]const u8, value: ?[*:0]const u8) callconv(.c) void;

pub const PlaydateHTTP = extern struct {
    requestAccess: *const fn (server: ?[*:0]const u8, port: c_int, usessl: bool, purpose: ?[*:0]const u8, requestCallback: AccessRequestCallback, userdata: ?*anyopaque) callconv(.c) AccessReply,

    newConnection: *const fn (server: ?[*:0]const u8, port: c_int, usessl: bool) callconv(.c) ?*HTTPConnection,
    retain: *const fn (http: ?*HTTPConnection) callconv(.c) ?*HTTPConnection,
    release: *const fn (http: ?*HTTPConnection) callconv(.c) void,

    setConnectTimeout: *const fn (connection: ?*HTTPConnection, ms: c_int) callconv(.c) void,
    setKeepAlive: *const fn (connection: ?*HTTPConnection, keepalive: bool) callconv(.c) void,
    setByteRange: *const fn (connection: ?*HTTPConnection, start: c_int, end: c_int) callconv(.c) void,
    setUserdata: *const fn (connection: ?*HTTPConnection, userdata: ?*anyopaque) callconv(.c) void,
    getUserdata: *const fn (connection: ?*HTTPConnection) callconv(.c) ?*anyopaque,

    get: *const fn (connection: ?*HTTPConnection, path: ?[*:0]const u8, headers: ?[*:0]const u8, headerlen: usize) callconv(.c) PDNetErr,
    post: *const fn (connection: ?*HTTPConnection, path: ?[*:0]const u8, headers: ?[*:0]const u8, headerlen: usize, body: ?[*:0]const u8, bodylen: usize) callconv(.c) PDNetErr,
    query: *const fn (connection: ?*HTTPConnection, method: ?[*:0]const u8, path: ?[*:0]const u8, headers: ?[*:0]const u8, headerlen: usize, body: ?[*:0]const u8, bodylen: usize) callconv(.c) PDNetErr,
    getError: *const fn (connection: ?*HTTPConnection) callconv(.c) PDNetErr,
    getProgress: *const fn (connection: ?*HTTPConnection, read: ?*c_int, total: ?*c_int) callconv(.c) void,
    getResponseStatus: *const fn (connection: ?*HTTPConnection) callconv(.c) c_int,
    getBytesAvailable: *const fn (connection: ?*HTTPConnection) callconv(.c) usize,
    setReadTimeout: *const fn (connection: ?*HTTPConnection, ms: c_int) callconv(.c) void,
    setReadBufferSize: *const fn (connection: ?*HTTPConnection, bytes: c_int) callconv(.c) void,
    read: *const fn (connection: ?*HTTPConnection, buf: [*c]u8, buflen: c_uint) callconv(.c) c_int,
    close: *const fn (connection: ?*HTTPConnection) callconv(.c) void,

    setHeaderReceivedCallback: *const fn (connection: ?*HTTPConnection, headercb: HTTPHeaderCallback) callconv(.c) void,
    setHeadersReadCallback: *const fn (connection: ?*HTTPConnection, callback: HTTPConnectionCallback) callconv(.c) void,
    setResponseCallback: *const fn (connection: ?*HTTPConnection, callback: HTTPConnectionCallback) callconv(.c) void,
    setRequestCompleteCallback: *const fn (connection: ?*HTTPConnection, callback: HTTPConnectionCallback) callconv(.c) void,
    setConnectionClosedCallback: *const fn (connection: ?*HTTPConnection, callback: HTTPConnectionCallback) callconv(.c) void,
};

pub const TCPConnectionCallback = ?*const fn (connection: ?*TCPConnection, err: PDNetErr) callconv(.c) void;
pub const TCPOpenCallback = ?*const fn (connection: ?*TCPConnection, err: PDNetErr, ud: ?*anyopaque) callconv(.c) void;

pub const PlaydateTCP = extern struct {
    requestAccess: *const fn (server: ?[*:0]const u8, port: c_int, usessl: bool, purpose: ?[*:0]const u8, requestCallback: AccessRequestCallback, userdata: ?*anyopaque) callconv(.c) AccessReply,

    newConnection: *const fn (server: ?[*:0]const u8, port: c_int, usessl: bool) callconv(.c) ?*TCPConnection,
    retain: *const fn (tcp: ?*TCPConnection) callconv(.c) ?*TCPConnection,
    release: *const fn (tcp: ?*TCPConnection) callconv(.c) void,
    getError: *const fn (connection: ?*TCPConnection) callconv(.c) PDNetErr,

    setConnectTimeout: *const fn (connection: ?*TCPConnection, ms: c_int) callconv(.c) void,
    setUserdata: *const fn (connection: ?*TCPConnection, userdata: ?*anyopaque) callconv(.c) void,
    getUserdata: *const fn (connection: ?*TCPConnection) callconv(.c) ?*anyopaque,

    open: *const fn (connection: ?*TCPConnection, cb: TCPOpenCallback, ud: ?*anyopaque) callconv(.c) PDNetErr,
    close: *const fn (connection: ?*TCPConnection) callconv(.c) PDNetErr,

    setConnectionClosedCallback: *const fn (connection: ?*TCPConnection, callback: TCPConnectionCallback) callconv(.c) void,

    setReadTimeout: *const fn (connection: ?*TCPConnection, ms: c_int) callconv(.c) void,
    setReadBufferSize: *const fn (connection: ?*TCPConnection, bytes: c_int) callconv(.c) void,
    getBytesAvailable: *const fn (connection: ?*TCPConnection) callconv(.c) usize,

    read: *const fn (connection: ?*TCPConnection, buffer: [*c]u8, length: usize) callconv(.c) c_int, // returns # of bytes read, or PDNetErr on error
    write: *const fn (connection: ?*TCPConnection, buffer: [*c]const u8, length: usize) callconv(.c) c_int, // returns # of bytes read, or PDNetErr on error
};

pub const PlaydateNetwork = extern struct {
    playdate_http: *const PlaydateHTTP,
    playdate_tcp: *const PlaydateTCP,

    getStatus: *const fn () callconv(.c) WifiStatus,
    setEnabled: *const fn (flag: bool, callback: ?*const fn (err: PDNetErr) callconv(.c) void) callconv(.c) void,

    reserved: [3]usize,
};
