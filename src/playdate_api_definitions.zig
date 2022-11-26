const std = @import("std");

pub const PlaydateAPI = extern struct {
    system: *const PlaydateSys,
    file: *const PlaydateFile,
    graphics: *const PlaydateGraphics,
    sprite: *anyopaque,
    display: *const PlaydateDisplay,
    sound: *const PlaydateSound,
    lua: *anyopaque,
    json: *anyopaque,
    scoreboards: *anyopaque,
};

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
pub const PDCallbackFunction = *const fn (userdata: ?*anyopaque) callconv(.C) c_int;
pub const PDMenuItemCallbackFunction = *const fn (userdata: ?*anyopaque) callconv(.C) void;
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

pub const PDPeripherals = c_int;
const PERIPHERAL_NONE = 0;
const PERIPHERAL_ACCELEROMETER = (1 << 0);
// ...
const PERIPHERAL_ALL = 0xFFFF;

pub const PDStringEncoding = enum(c_int) {
    ASCIIEncoding,
    UTF8Encoding,
    @"16BitLEEncoding",
};

pub const PlaydateSys = extern struct {
    realloc: *const fn (ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque,
    formatString: *const fn (ret: ?*[*c]u8, fmt: [*c]const u8, ...) callconv(.C) c_int,
    logToConsole: *const fn (fmt: [*c]const u8, ...) callconv(.C) void,
    @"error": *const fn (fmt: [*c]const u8, ...) callconv(.C) void,
    getLanguage: *const fn () callconv(.C) PDLanguage,
    getCurrentTimeMilliseconds: *const fn () callconv(.C) c_uint,
    getSecondsSinceEpoch: *const fn (milliseconds: ?*c_uint) callconv(.C) c_uint,
    drawFPS: *const fn (x: c_int, y: c_int) callconv(.C) void,

    setUpdateCallback: *const fn (update: ?PDCallbackFunction, userdata: ?*anyopaque) callconv(.C) void,
    getButtonState: *const fn (current: ?*PDButtons, pushed: ?*PDButtons, released: ?*PDButtons) callconv(.C) void,
    setPeripheralsEnabled: *const fn (mask: PDPeripherals) callconv(.C) void,
    getAccelerometer: *const fn (outx: ?*f32, outy: ?*f32, outz: ?*f32) callconv(.C) void,
    getCrankChange: *const fn () callconv(.C) f32,
    getCrankAngle: *const fn () callconv(.C) f32,
    isCrankDocked: *const fn () callconv(.C) c_int,
    setCrankSoundsDisabled: *const fn (flag: c_int) callconv(.C) c_int, // returns previous setting

    getFlipped: *const fn () callconv(.C) c_int,
    setAutoLockDisabled: *const fn (disable: c_int) callconv(.C) void,

    setMenuImage: *const fn (bitmap: ?*LCDBitmap, xOffset: c_int) callconv(.C) void,
    addMenuItem: *const fn (title: [*c]const u8, callback: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.C) ?*PDMenuItem,
    addCheckmarkMenuItem: *const fn (title: [*c]const u8, value: c_int, callback: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.C) ?*PDMenuItem,
    addOptionsMenuItem: *const fn (title: [*c]const u8, optionTitles: [*c][*c]const u8, optionsCount: c_int, f: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.C) ?*PDMenuItem,
    removeAllMenuItems: *const fn () callconv(.C) void,
    removeMenuItem: *const fn (menuItem: ?*PDMenuItem) callconv(.C) void,
    getMenuItemValue: *const fn (menuItem: ?*PDMenuItem) callconv(.C) c_int,
    setMenuItemValue: *const fn (menuItem: ?*PDMenuItem, value: c_int) callconv(.C) void,
    getMenuItemTitle: *const fn (menuItem: ?*PDMenuItem) callconv(.C) [*c]const u8,
    setMenuItemTitle: *const fn (menuItem: ?*PDMenuItem, title: [*c]const u8) callconv(.C) void,
    getMenuItemUserdata: *const fn (menuItem: ?*PDMenuItem) callconv(.C) ?*anyopaque,
    setMenuItemUserdata: *const fn (menuItem: ?*PDMenuItem, ud: ?*anyopaque) callconv(.C) void,

    getReduceFlashing: *const fn () callconv(.C) c_int,

    // 1.1
    getElapsedTime: *const fn () callconv(.C) f32,
    resetElapsedTime: *const fn () callconv(.C) void,

    // 1.4
    getBatteryPercentage: *const fn () callconv(.C) f32,
    getBatteryVoltage: *const fn () callconv(.C) f32,
};

////////LCD and Graphics///////////////////////
pub const LCD_COLUMNS = 400;
pub const LCD_ROWS = 240;
pub const LCD_ROWSIZE = 52;
pub const LCDBitmap = opaque {};
pub const LCDVideoPlayer = opaque {};
pub const PlaydateVideo = extern struct {
    loadVideo: *const fn ([*c]const u8) callconv(.C) ?*LCDVideoPlayer,
    freePlayer: *const fn (?*LCDVideoPlayer) callconv(.C) void,
    setContext: *const fn (?*LCDVideoPlayer, ?*LCDBitmap) callconv(.C) c_int,
    useScreenContext: *const fn (?*LCDVideoPlayer) callconv(.C) void,
    renderFrame: *const fn (?*LCDVideoPlayer, c_int) callconv(.C) c_int,
    getError: *const fn (?*LCDVideoPlayer) callconv(.C) [*c]const u8,
    getInfo: *const fn (?*LCDVideoPlayer, [*c]c_int, [*c]c_int, [*c]f32, [*c]c_int, [*c]c_int) callconv(.C) void,
    getContext: *const fn (?*LCDVideoPlayer) callconv(.C) ?*LCDBitmap,
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

pub const PlaydateGraphics = extern struct {
    video: *const PlaydateVideo,
    // Drawing Functions
    clear: *const fn (color: LCDColor) callconv(.C) void,
    setBackgroundColor: *const fn (color: LCDSolidColor) callconv(.C) void,
    setStencil: *const fn (stencil: ?*LCDBitmap) callconv(.C) void, // deprecated in favor of setStencilImage, which adds a "tile" flag
    setDrawMode: *const fn (mode: LCDBitmapDrawMode) callconv(.C) void,
    setDrawOffset: *const fn (dx: c_int, dy: c_int) callconv(.C) void,
    setClipRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) callconv(.C) void,
    clearClipRect: *const fn () callconv(.C) void,
    setLineCapStyle: *const fn (endCapStyle: LCDLineCapStyle) callconv(.C) void,
    setFont: *const fn (font: ?*LCDFont) callconv(.C) void,
    setTextTracking: *const fn (tracking: c_int) callconv(.C) void,
    pushContext: *const fn (target: ?*LCDBitmap) callconv(.C) void,
    popContext: *const fn () callconv(.C) void,

    drawBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, flip: LCDBitmapFlip) callconv(.C) void,
    tileBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, width: c_int, height: c_int, flip: LCDBitmapFlip) callconv(.C) void,
    drawLine: *const fn (x1: c_int, y1: c_int, x2: c_int, y2: c_int, width: c_int, color: LCDColor) callconv(.C) void,
    fillTriangle: *const fn (x1: c_int, y1: c_int, x2: c_int, y2: c_int, x3: c_int, y3: c_int, color: LCDColor) callconv(.C) void,
    drawRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, color: LCDColor) callconv(.C) void,
    fillRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, color: LCDColor) callconv(.C) void,
    drawEllipse: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, lineWidth: c_int, startAngle: f32, endAngle: f32, color: LCDColor) callconv(.C) void,
    fillEllipse: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, startAngle: f32, endAngle: f32, color: LCDColor) callconv(.C) void,
    drawScaledBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, xscale: f32, yscale: f32) callconv(.C) void,
    drawText: *const fn (text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, x: c_int, y: c_int) callconv(.C) c_int,

    // LCDBitmap
    newBitmap: *const fn (width: c_int, height: c_int, color: LCDColor) callconv(.C) ?*LCDBitmap,
    freeBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.C) void,
    loadBitmap: *const fn (path: [*c]const u8, outerr: ?*[*c]const u8) callconv(.C) ?*LCDBitmap,
    copyBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.C) ?*LCDBitmap,
    loadIntoBitmap: *const fn (path: [*c]const u8, bitmap: ?*LCDBitmap, outerr: ?*[*c]const u8) callconv(.C) void,
    getBitmapData: *const fn (bitmap: ?*LCDBitmap, width: ?*c_int, height: ?*c_int, rowbytes: ?*c_int, mask: ?*[*c]u8, data: ?*[*c]u8) callconv(.C) void,
    clearBitmap: *const fn (bitmap: ?*LCDBitmap, bgcolor: LCDColor) callconv(.C) void,
    rotatedBitmap: *const fn (bitmap: ?*LCDBitmap, rotation: f32, xscale: f32, yscale: f32, allocedSize: ?*c_int) callconv(.C) ?*LCDBitmap,

    // LCDBitmapTable
    newBitmapTable: *const fn (count: c_int, width: c_int, height: c_int) callconv(.C) ?*LCDBitmapTable,
    freeBitmapTable: *const fn (table: ?*LCDBitmapTable) callconv(.C) void,
    loadBitmapTable: *const fn (path: [*c]const u8, outerr: ?*[*c]const u8) callconv(.C) ?*LCDBitmapTable,
    loadIntoBitmapTable: *const fn (path: [*c]const u8, table: ?*LCDBitmapTable, outerr: ?*[*c]const u8) callconv(.C) void,
    getTableBitmap: *const fn (table: ?*LCDBitmapTable, idx: c_int) callconv(.C) ?*LCDBitmap,

    // LCDFont
    loadFont: *const fn (path: [*c]const u8, outErr: ?*[*c]const u8) callconv(.C) ?*LCDFont,
    getFontPage: *const fn (font: ?*LCDFont, c: u32) callconv(.C) ?*LCDFontPage,
    getPageGlyph: *const fn (page: ?*LCDFontPage, c: u32, bitmap: ?**LCDBitmap, advance: ?*c_int) callconv(.C) ?*LCDFontGlyph,
    getGlyphKerning: *const fn (glyph: ?*LCDFontGlyph, glyphcode: u32, nextcode: u32) callconv(.C) c_int,
    getTextWidth: *const fn (font: ?*LCDFont, text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, tracking: c_int) callconv(.C) c_int,

    // raw framebuffer access
    getFrame: *const fn () callconv(.C) [*c]u8, // row stride = LCD_ROWSIZE
    getDisplayFrame: *const fn () callconv(.C) [*c]u8, // row stride = LCD_ROWSIZE
    getDebugBitmap: ?*const fn () callconv(.C) ?*LCDBitmap, // valid in simulator only, function is null on device
    copyFrameBufferBitmap: *const fn () callconv(.C) ?*LCDBitmap,
    markUpdatedRows: *const fn (start: c_int, end: c_int) callconv(.C) void,
    display: *const fn () callconv(.C) void,

    // misc util.
    setColorToPattern: *const fn (color: ?*LCDColor, bitmap: ?*LCDBitmap, x: c_int, y: c_int) callconv(.C) void,
    checkMaskCollision: *const fn (bitmap1: ?*LCDBitmap, x1: c_int, y1: c_int, flip1: LCDBitmapFlip, bitmap2: ?*LCDBitmap, x2: c_int, y2: c_int, flip2: LCDBitmapFlip, rect: LCDRect) callconv(.C) c_int,

    // 1.1
    setScreenClipRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) callconv(.C) void,

    // 1.1.1
    fillPolygon: *const fn (nPoints: c_int, coords: [*c]c_int, color: LCDColor, fillRule: LCDPolygonFillRule) callconv(.C) void,
    getFontHeight: *const fn (font: ?*LCDFont) callconv(.C) u8,

    // 1.7
    getDisplayBufferBitmap: *const fn () callconv(.C) ?*LCDBitmap,
    drawRotatedBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, rotation: f32, centerx: f32, centery: f32, xscale: f32, yscale: f32) callconv(.C) void,
    setTextLeading: *const fn (lineHeightAdustment: c_int) callconv(.C) void,

    // 1.8
    setBitmapMask: *const fn (bitmap: ?*LCDBitmap, mask: ?*LCDBitmap) callconv(.C) c_int,
    getBitmapMask: *const fn (bitmap: ?*LCDBitmap) callconv(.C) ?*LCDBitmap,

    // 1.10
    setStencilImage: *const fn (stencil: ?*LCDBitmap, tile: c_int) callconv(.C) void,

    // 1.12
    makeFontFromData: *const fn (data: *LCDFontData, wide: c_int) callconv(.C) *LCDFont,
};
pub const PlaydateDisplay = struct {
    getWidth: *const fn () callconv(.C) c_int,
    getHeight: *const fn () callconv(.C) c_int,

    setRefreshRate: *const fn (rate: f32) callconv(.C) void,

    setInverted: *const fn (flag: c_int) callconv(.C) void,
    setScale: *const fn (s: c_uint) callconv(.C) void,
    setMosaic: *const fn (x: c_uint, y: c_uint) callconv(.C) void,
    setFlipped: *const fn (x: c_uint, y: c_uint) callconv(.C) void,
    setOffset: *const fn (x: c_uint, y: c_uint) callconv(.C) void,
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

const FileStat = extern struct {
    isdir: c_int,
    size: c_uint,
    m_year: c_int,
    m_month: c_int,
    m_day: c_int,
    m_hour: c_int,
    m_minute: c_int,
    m_second: c_int,
};

const PlaydateFile = extern struct {
    geterr: *const fn () callconv(.C) [*c]const u8,

    listfiles: *const fn (
        path: [*c]const u8,
        callback: *const fn (path: [*c]const u8, userdata: ?*anyopaque) callconv(.C) void,
        userdata: ?*anyopaque,
        showhidden: c_int,
    ) callconv(.C) c_int,
    stat: *const fn (path: [*c]const u8, stat: ?*FileStat) callconv(.C) c_int,
    mkdir: *const fn (path: [*c]const u8) callconv(.C) c_int,
    unlink: *const fn (name: [*c]const u8, recursive: c_int) callconv(.C) c_int,
    rename: *const fn (from: [*c]const u8, to: [*c]const u8) callconv(.C) c_int,

    open: *const fn (name: [*c]const u8, mode: FileOptions) callconv(.C) ?*SDFile,
    close: *const fn (file: ?*SDFile) callconv(.C) c_int,
    read: *const fn (file: ?*SDFile, buf: ?*anyopaque, len: c_uint) callconv(.C) c_int,
    write: *const fn (file: ?*SDFile, buf: ?*const anyopaque, len: c_uint) callconv(.C) c_int,
    flush: *const fn (file: ?*SDFile) callconv(.C) c_int,
    tell: *const fn (file: ?*SDFile) callconv(.C) c_int,
    seek: *const fn (file: ?*SDFile, pos: c_int, whence: c_int) callconv(.C) c_int,
};

/////////Audio//////////////
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

    getCurrentTime: *const fn () callconv(.C) u32,
    addSource: *const fn (callback: AudioSourceFunction, context: ?*anyopaque, stereo: c_int) callconv(.C) ?*SoundSource,

    getDefaultChannel: *const fn () callconv(.C) ?*SoundChannel,

    addChannel: *const fn (channel: ?*SoundChannel) callconv(.C) void,
    removeChannel: *const fn (channel: ?*SoundChannel) callconv(.C) void,

    setMicCallback: *const fn (callback: RecordCallback, context: ?*anyopaque, forceInternal: c_int) callconv(.C) void,
    getHeadphoneState: *const fn (headphone: ?*c_int, headsetmic: ?*c_int, changeCallback: *const fn (headphone: c_int, mic: c_int) callconv(.C) void) callconv(.C) void,
    setOutputsActive: *const fn (headphone: c_int, mic: c_int) callconv(.C) void,

    // 1.5
    removeSource: *const fn (?*SoundSource) callconv(.C) void,

    // 1.12
    signal: *const PlaydateSoundSignal,
};

//data is mono
pub const RecordCallback = *const fn (context: ?*anyopaque, buffer: [*c]i16, length: c_int) callconv(.C) c_int;
// len is # of samples in each buffer, function should return 1 if it produced output
pub const AudioSourceFunction = *const fn (context: ?*anyopaque, left: [*c]i16, right: [*c]i16, len: c_int) callconv(.C) c_int;
pub const SndCallbackProc = *const fn (c: ?*SoundSource) callconv(.C) void;

pub const SoundChannel = opaque {};
pub const SoundSource = opaque {};
pub const SoundEffect = opaque {};
pub const PDSynthSignalValue = opaque {};

pub const PlaydateSoundChannel = extern struct {
    newChannel: *const fn () callconv(.C) ?*SoundChannel,
    freeChannel: *const fn (channel: ?*SoundChannel) callconv(.C) void,
    addSource: *const fn (channel: ?*SoundChannel, source: ?*SoundSource) callconv(.C) c_int,
    removeSource: *const fn (channel: ?*SoundChannel, source: ?*SoundSource) callconv(.C) c_int,
    addCallbackSource: *const fn (?*SoundChannel, AudioSourceFunction, ?*anyopaque, c_int) callconv(.C) ?*SoundSource,
    addEffect: *const fn (channel: ?*SoundChannel, effect: ?*SoundEffect) callconv(.C) void,
    removeEffect: *const fn (channel: ?*SoundChannel, effect: ?*SoundEffect) callconv(.C) void,
    setVolume: *const fn (channel: ?*SoundChannel, f32) callconv(.C) void,
    getVolume: *const fn (channel: ?*SoundChannel) callconv(.C) f32,
    setVolumeModulator: *const fn (channel: ?*SoundChannel, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getVolumeModulator: *const fn (channel: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
    setPan: *const fn (channel: ?*SoundChannel, pan: f32) callconv(.C) void,
    setPanModulator: *const fn (channel: ?*SoundChannel, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getPanModulator: *const fn (channel: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
    getDryLevelSignal: *const fn (channe: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
    getWetLevelSignal: *const fn (channel: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
};

pub const FilePlayer = SoundSource;
//TODO: fill in parameters
pub const PlaydateSoundFileplayer = extern struct {
    newPlayer: *const fn () callconv(.C) ?*FilePlayer,
    freePlayer: *const fn (player: ?*FilePlayer) callconv(.C) void,
    loadIntoPlayer: *const fn (player: ?*FilePlayer, path: [*c]const u8) callconv(.C) c_int,
    setBufferLength: *const fn (player: ?*FilePlayer, bufferLen: f32) callconv(.C) void,
    play: *const fn (player: ?*FilePlayer, repeat: c_int) callconv(.C) c_int,
    isPlaying: *const fn (player: ?*FilePlayer) callconv(.C) c_int,
    pause: *const fn (player: ?*FilePlayer) callconv(.C) void,
    stop: *const fn (player: ?*FilePlayer) callconv(.C) void,
    setVolume: *const fn (player: ?*FilePlayer, left: f32, right: f32) callconv(.C) void,
    getVolume: *const fn (player: ?*FilePlayer, left: ?*f32, right: ?*f32) callconv(.C) void,
    getLength: *const fn (player: ?*FilePlayer) callconv(.C) f32,
    setOffset: *const fn (player: ?*FilePlayer, offset: f32) callconv(.C) void,
    setRate: *const fn (player: ?*FilePlayer, rate: f32) callconv(.C) void,
    setLoopRange: *const fn (player: ?*FilePlayer, start: f32, end: f32) callconv(.C) void,
    didUnderrun: *const fn (player: ?*FilePlayer) callconv(.C) c_int,
    setFinishCallback: *const fn (player: ?*FilePlayer, callback: SndCallbackProc) callconv(.C) void,
    setLoopCallback: *const fn (player: ?*FilePlayer, callback: SndCallbackProc) callconv(.C) void,
    getOffset: *const fn (player: ?*FilePlayer) callconv(.C) f32,
    getRate: *const fn (player: ?*FilePlayer) callconv(.C) f32,
    setStopOnUnderrun: *const fn (player: ?*FilePlayer, flag: c_int) callconv(.C) void,
    fadeVolume: *const fn (player: ?*FilePlayer, left: f32, right: f32, len: i32, finishCallback: SndCallbackProc) callconv(.C) void,
    setMP3StreamSource: *const fn (
        player: ?*FilePlayer,
        dataSource: *const fn (data: [*c]u8, bytes: c_int, userdata: ?*anyopaque) callconv(.C) c_int,
        userdata: ?*anyopaque,
        bufferLen: f32,
    ) callconv(.C) void,
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
    return @enumToInt(f) & 1;
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

//TODO: fill in parameters
pub const PlaydateSoundSample = extern struct {
    newSampleBuffer: *const fn (c_int) callconv(.C) ?*AudioSample,
    loadIntoSample: *const fn (?*AudioSample, [*c]const u8) callconv(.C) c_int,
    load: *const fn ([*c]const u8) callconv(.C) ?*AudioSample,
    newSampleFromData: *const fn ([*c]u8, SoundFormat, u32, c_int) callconv(.C) ?*AudioSample,
    getData: *const fn (?*AudioSample, [*c][*c]u8, [*c]SoundFormat, [*c]u32, [*c]u32) callconv(.C) void,
    freeSample: *const fn (?*AudioSample) callconv(.C) void,
    getLength: *const fn (?*AudioSample) callconv(.C) f32,
};

//TODO: fill in parameters
pub const PlaydateSoundSampleplayer = extern struct {
    newPlayer: *const fn () callconv(.C) ?*SamplePlayer,
    freePlayer: *const fn (?*SamplePlayer) callconv(.C) void,
    setSample: *const fn (?*SamplePlayer, ?*AudioSample) callconv(.C) void,
    play: *const fn (?*SamplePlayer, c_int, f32) callconv(.C) c_int,
    isPlaying: *const fn (?*SamplePlayer) callconv(.C) c_int,
    stop: *const fn (?*SamplePlayer) callconv(.C) void,
    setVolume: *const fn (?*SamplePlayer, f32, f32) callconv(.C) void,
    getVolume: *const fn (?*SamplePlayer, [*c]f32, [*c]f32) callconv(.C) void,
    getLength: *const fn (?*SamplePlayer) callconv(.C) f32,
    setOffset: *const fn (?*SamplePlayer, f32) callconv(.C) void,
    setRate: *const fn (?*SamplePlayer, f32) callconv(.C) void,
    setPlayRange: *const fn (?*SamplePlayer, c_int, c_int) callconv(.C) void,
    setFinishCallback: *const fn (?*SamplePlayer, SndCallbackProc) callconv(.C) void,
    setLoopCallback: *const fn (?*SamplePlayer, SndCallbackProc) callconv(.C) void,
    getOffset: *const fn (?*SamplePlayer) callconv(.C) f32,
    getRate: *const fn (?*SamplePlayer) callconv(.C) f32,
    setPaused: *const fn (?*SamplePlayer, c_int) callconv(.C) void,
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
pub const SynthRenderFunc = *const fn (userdata: ?*anyopaque, left: [*c]i32, right: [*c]i32, nsamples: c_int, rate: u32, drate: i32) callconv(.C) c_int;

// generator event callbacks

// len == -1 if indefinite
pub const SynthNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, velocity: f32, len: f32) callconv(.C) void;

pub const SynthReleaseFunc = *const fn (?*anyopaque, c_int) callconv(.C) void;
pub const SynthSetParameterFunc = *const fn (?*anyopaque, c_int, f32) callconv(.C) c_int;
pub const SynthDeallocFunc = *const fn (?*anyopaque) callconv(.C) void;

//TODO: fill in parameters
pub const PlaydateSoundSynth = extern struct {
    newSynth: *const fn () callconv(.C) ?*PDSynth,
    freeSynth: *const fn (synth: ?*PDSynth) callconv(.C) void,

    setWaveform: *const fn (synth: ?*PDSynth, wave: SoundWaveform) callconv(.C) void,
    setGenerator: *const fn (
        synth: ?*PDSynth,
        stereo: c_int,
        render: SynthRenderFunc,
        note_on: SynthNoteOnFunc,
        release: SynthReleaseFunc,
        set_param: SynthSetParameterFunc,
        dealloc: SynthDeallocFunc,
        userdata: ?*anyopaque,
    ) callconv(.C) void,
    setSample: *const fn (
        synth: ?*PDSynth,
        sample: ?*AudioSample,
        sustain_start: u32,
        sustain_end: u32,
    ) callconv(.C) void,

    setAttackTime: *const fn (synth: ?*PDSynth, attack: f32) callconv(.C) void,
    setDecayTime: *const fn (synth: ?*PDSynth, decay: f32) callconv(.C) void,
    setSustainLevel: *const fn (synth: ?*PDSynth, sustain: f32) callconv(.C) void,
    setReleaseTime: *const fn (synth: ?*PDSynth, release: f32) callconv(.C) void,

    setTranspose: *const fn (synth: ?*PDSynth, half_steps: f32) callconv(.C) void,

    setFrequencyModulator: *const fn (synth: ?*PDSynth, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getFrequencyModulator: *const fn (synth: ?*PDSynth) callconv(.C) ?*PDSynthSignalValue,
    setAmplitudeModulator: *const fn (synth: ?*PDSynth, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getAmplitudeModulator: *const fn (synth: ?*PDSynth) callconv(.C) ?*PDSynthSignalValue,

    getParameterCount: *const fn (synth: ?*PDSynth) callconv(.C) c_int,
    setParameter: *const fn (synth: ?*PDSynth, parameter: c_int, value: f32) callconv(.C) c_int,
    setParameterModulator: *const fn (synth: ?*PDSynth, parameter: c_int, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getParameterModulator: *const fn (synth: ?*PDSynth, parameter: c_int) callconv(.C) ?*PDSynthSignalValue,

    playNote: *const fn (synth: ?*PDSynth, freq: f32, vel: f32, len: f32, when: u32) callconv(.C) void,
    playMIDINote: *const fn (synth: ?*PDSynth, note: MIDINote, vel: f32, len: f32, when: u32) callconv(.C) void,
    noteOff: *const fn (synth: ?*PDSynth, when: u32) callconv(.C) void,
    stop: *const fn (synth: ?*PDSynth) callconv(.C) void,

    setVolume: *const fn (synth: ?*PDSynth, left: f32, right: f32) callconv(.C) void,
    getVolume: *const fn (synth: ?*PDSynth, left: ?*f32, right: ?*f32) callconv(.C) void,

    isPlaying: *const fn (synth: ?*PDSynth) callconv(.C) c_int,
};

pub const SequenceTrack = opaque {};
pub const SoundSequence = opaque {};
pub const SequenceFinishedCallback = *const fn (seq: ?*SoundSequence, userdata: ?*anyopaque) callconv(.C) void;
//TODO: fill in parameters
pub const PlaydateSoundSequence = extern struct {
    newSequence: *const fn () callconv(.C) ?*SoundSequence,
    freeSequence: *const fn (?*SoundSequence) callconv(.C) void,

    loadMidiFile: *const fn (?*SoundSequence, [*c]const u8) callconv(.C) c_int,
    getTime: *const fn (?*SoundSequence) callconv(.C) u32,
    setTime: *const fn (?*SoundSequence, u32) callconv(.C) void,
    setLoops: *const fn (?*SoundSequence, c_int, c_int, c_int) callconv(.C) void,
    getTempo: *const fn (?*SoundSequence) callconv(.C) c_int,
    setTempo: *const fn (?*SoundSequence, c_int) callconv(.C) void,
    getTrackCount: *const fn (?*SoundSequence) callconv(.C) c_int,
    addTrack: *const fn (?*SoundSequence) callconv(.C) ?*SequenceTrack,
    getTrackAtIndex: *const fn (?*SoundSequence, c_uint) callconv(.C) ?*SequenceTrack,
    setTrackAtIndex: *const fn (?*SoundSequence, ?*SequenceTrack, c_uint) callconv(.C) void,
    allNotesOff: *const fn (?*SoundSequence) callconv(.C) void,

    // 1.1
    isPlaying: *const fn (?*SoundSequence) callconv(.C) c_int,
    getLength: *const fn (?*SoundSequence) callconv(.C) u32,
    play: *const fn (?*SoundSequence, SequenceFinishedCallback, ?*anyopaque) callconv(.C) void,
    stop: *const fn (?*SoundSequence) callconv(.C) void,
    getCurrentStep: *const fn (?*SoundSequence, [*c]c_int) callconv(.C) c_int,
    setCurrentStep: *const fn (?*SoundSequence, c_int, c_int, c_int) callconv(.C) void,
};

pub const EffectProc = *const fn (e: ?*SoundEffect, left: [*c]i32, right: [*c]i32, nsamples: c_int, bufactive: c_int) callconv(.C) c_int;

//TODO: fill in parameters
pub const PlaydateSoundEffect = extern struct {
    newEffect: *const fn (?*const EffectProc, ?*anyopaque) callconv(.C) ?*SoundEffect,
    freeEffect: *const fn (?*SoundEffect) callconv(.C) void,

    setMix: *const fn (?*SoundEffect, f32) callconv(.C) void,
    setMixModulator: *const fn (?*SoundEffect, ?*PDSynthSignalValue) callconv(.C) void,
    getMixModulator: *const fn (?*SoundEffect) callconv(.C) ?*PDSynthSignalValue,

    setUserdata: *const fn (?*SoundEffect, ?*anyopaque) callconv(.C) void,
    getUserdata: *const fn (?*SoundEffect) callconv(.C) ?*anyopaque,

    //TODO fill in
    twopolefilter: *const anyopaque, //*const struct_playdate_sound_effect_twopolefilter,
    onepolefilter: *const anyopaque, //*const struct_playdate_sound_effect_onepolefilter,
    bitcrusher: *const anyopaque, //*const struct_playdate_sound_effect_bitcrusher,
    ringmodulator: *const anyopaque, //*const struct_playdate_sound_effect_ringmodulator,
    delayline: *const anyopaque, //*const struct_playdate_sound_effect_delayline,
    overdrive: *const anyopaque, //*const struct_playdate_sound_effect_overdrive,
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
//TODO: fill in parameters
pub const PlaydateSoundLFO = extern struct {
    newLFO: *const fn (LFOType) callconv(.C) ?*PDSynthLFO,
    freeLFO: *const fn (?*PDSynthLFO) callconv(.C) void,

    setType: *const fn (?*PDSynthLFO, LFOType) callconv(.C) void,
    setRate: *const fn (?*PDSynthLFO, f32) callconv(.C) void,
    setPhase: *const fn (?*PDSynthLFO, f32) callconv(.C) void,
    setCenter: *const fn (?*PDSynthLFO, f32) callconv(.C) void,
    setDepth: *const fn (?*PDSynthLFO, f32) callconv(.C) void,
    setArpeggiation: *const fn (?*PDSynthLFO, c_int, [*c]f32) callconv(.C) void,
    setFunction: *const fn (?*PDSynthLFO, *const fn (?*PDSynthLFO, ?*anyopaque) callconv(.C) f32, ?*anyopaque, c_int) callconv(.C) void,
    setDelay: *const fn (?*PDSynthLFO, f32, f32) callconv(.C) void,
    setRetrigger: *const fn (?*PDSynthLFO, c_int) callconv(.C) void,

    getValue: *const fn (?*PDSynthLFO) callconv(.C) f32,

    // 1.10
    setGlobal: *const fn (?*PDSynthLFO, c_int) callconv(.C) void,
};

pub const PDSynthEnvelope = opaque {};
//TODO: fill in parameters
pub const PlaydateSoundEnvelope = extern struct {
    newEnvelope: *const fn (f32, f32, f32, f32) callconv(.C) ?*PDSynthEnvelope,
    freeEnvelope: *const fn (?*PDSynthEnvelope) callconv(.C) void,

    setAttack: *const fn (?*PDSynthEnvelope, f32) callconv(.C) void,
    setDecay: *const fn (?*PDSynthEnvelope, f32) callconv(.C) void,
    setSustain: *const fn (?*PDSynthEnvelope, f32) callconv(.C) void,
    setRelease: *const fn (?*PDSynthEnvelope, f32) callconv(.C) void,

    setLegato: *const fn (?*PDSynthEnvelope, c_int) callconv(.C) void,
    setRetrigger: *const fn (?*PDSynthEnvelope, c_int) callconv(.C) void,

    getValue: *const fn (?*PDSynthEnvelope) callconv(.C) f32,
};

//TODO: fill in parameters
pub const PlaydateSoundSource = extern struct {
    setVolume: *const fn (?*SoundSource, f32, f32) callconv(.C) void,
    getVolume: *const fn (?*SoundSource, [*c]f32, [*c]f32) callconv(.C) void,
    isPlaying: *const fn (?*SoundSource) callconv(.C) c_int,
    setFinishCallback: *const fn (?*SoundSource, SndCallbackProc) callconv(.C) void,
};

pub const ControlSignal = opaque {};
//TODO: fill in parameters
pub const PlaydateControlSignal = extern struct {
    newSignal: *const fn () callconv(.C) ?*ControlSignal,
    freeSignal: *const fn (?*ControlSignal) callconv(.C) void,
    clearEvents: *const fn (?*ControlSignal) callconv(.C) void,
    addEvent: *const fn (?*ControlSignal, c_int, f32, c_int) callconv(.C) void,
    removeEvent: *const fn (?*ControlSignal, c_int) callconv(.C) void,
    getMIDIControllerNumber: *const fn (?*ControlSignal) callconv(.C) c_int,
};

//TODO: fill in parameters
pub const PlaydateSoundTrack = extern struct {
    newTrack: *const fn () callconv(.C) ?*SequenceTrack,
    freeTrack: *const fn (?*SequenceTrack) callconv(.C) void,
    setInstrument: *const fn (?*SequenceTrack, ?*PDSynthInstrument) callconv(.C) void,
    getInstrument: *const fn (?*SequenceTrack) callconv(.C) ?*PDSynthInstrument,
    addNoteEvent: *const fn (?*SequenceTrack, u32, u32, MIDINote, f32) callconv(.C) void,
    removeNoteEvent: *const fn (?*SequenceTrack, u32, MIDINote) callconv(.C) void,
    clearNotes: *const fn (?*SequenceTrack) callconv(.C) void,
    getControlSignalCount: *const fn (?*SequenceTrack) callconv(.C) c_int,
    getControlSignal: *const fn (?*SequenceTrack, c_int) callconv(.C) ?*ControlSignal,
    clearControlEvents: *const fn (?*SequenceTrack) callconv(.C) void,
    getPolyphony: *const fn (?*SequenceTrack) callconv(.C) c_int,
    activeVoiceCount: *const fn (?*SequenceTrack) callconv(.C) c_int,
    setMuted: *const fn (?*SequenceTrack, c_int) callconv(.C) void,
    getLength: *const fn (?*SequenceTrack) callconv(.C) u32,
    getIndexForStep: *const fn (?*SequenceTrack, u32) callconv(.C) c_int,
    getNoteAtIndex: *const fn (?*SequenceTrack, c_int, [*c]u32, [*c]u32, [*c]MIDINote, [*c]f32) callconv(.C) c_int,
    getSignalForController: *const fn (?*SequenceTrack, c_int, c_int) callconv(.C) ?*ControlSignal,
};
//TODO: fill in parameters
pub const PDSynthInstrument = SoundSource;
pub const PlaydateSoundInstrument = extern struct {
    newInstrument: *const fn () callconv(.C) ?*PDSynthInstrument,
    freeInstrument: *const fn (?*PDSynthInstrument) callconv(.C) void,
    addVoice: *const fn (?*PDSynthInstrument, ?*PDSynth, MIDINote, MIDINote, f32) callconv(.C) c_int,
    playNote: *const fn (?*PDSynthInstrument, f32, f32, f32, u32) callconv(.C) ?*PDSynth,
    playMIDINote: *const fn (?*PDSynthInstrument, MIDINote, f32, f32, u32) callconv(.C) ?*PDSynth,
    setPitchBend: *const fn (?*PDSynthInstrument, f32) callconv(.C) void,
    setPitchBendRange: *const fn (?*PDSynthInstrument, f32) callconv(.C) void,
    setTranspose: *const fn (?*PDSynthInstrument, f32) callconv(.C) void,
    noteOff: *const fn (?*PDSynthInstrument, MIDINote, u32) callconv(.C) void,
    allNotesOff: *const fn (?*PDSynthInstrument, u32) callconv(.C) void,
    setVolume: *const fn (?*PDSynthInstrument, f32, f32) callconv(.C) void,
    getVolume: *const fn (?*PDSynthInstrument, [*c]f32, [*c]f32) callconv(.C) void,
    activeVoiceCount: *const fn (?*PDSynthInstrument) callconv(.C) c_int,
};

pub const PDSynthSignal = opaque {};

pub const SignalStepFunc = *const fn (userdata: ?*anyopaque, ioframes: [*c]c_int, ifval: ?*f32) callconv(.C) f32;

// len = -1 for indefinite
pub const SignalNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, vel: f32, len: f32) callconv(.C) void;
// ended = 0 for note release, = 1 when note stops playing
pub const SignalNoteOffFunc = *const fn (userdata: ?*anyopaque, stopped: c_int, offset: c_int) callconv(.C) void;

pub const SignalDeallocFunc = *const fn (userdata: ?*anyopaque) callconv(.C) void;

//TODO: fill in parameters
pub const PlaydateSoundSignal = struct {
    newSignal: ?*const fn (SignalStepFunc, SignalNoteOnFunc, SignalNoteOffFunc, SignalDeallocFunc, ?*anyopaque) callconv(.C) ?*PDSynthSignal,
    freeSignal: ?*const fn (?*PDSynthSignal) callconv(.C) void,
    getValue: ?*const fn (?*PDSynthSignal) callconv(.C) f32,
    setValueScale: ?*const fn (?*PDSynthSignal, f32) callconv(.C) void,
    setValueOffset: ?*const fn (?*PDSynthSignal, f32) callconv(.C) void,
};
