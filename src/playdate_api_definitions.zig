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

    // 1.13
    getTimezoneOffset: *const fn () callconv(.C) i32,
    shouldDisplay24HourTime: *const fn () callconv(.C) c_int,
    convertEpochToDateTime: *const fn (epoch: u32, datetime: ?*PDDateTime) callconv(.C) void,
    convertDateTimeToEpoch: *const fn (datetime: ?*PDDateTime) callconv(.C) u32,

    //2.0
    clearICache: *const fn () callconv(.C) void,
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
    getDebugBitmap: *const fn () callconv(.C) ?*LCDBitmap, // valid in simulator only, function is null on device
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
    newSampleBuffer: *const fn (byteCount: c_int) callconv(.C) ?*AudioSample,
    loadIntoSample: *const fn (sample: ?*AudioSample, path: [*c]const u8) callconv(.C) c_int,
    load: *const fn (path: [*c]const u8) callconv(.C) ?*AudioSample,
    newSampleFromData: *const fn (data: [*c]u8, format: SoundFormat, sampleRate: u32, byteCount: c_int) callconv(.C) ?*AudioSample,
    getData: *const fn (sample: ?*AudioSample, data: ?*[*c]u8, format: [*c]SoundFormat, sampleRate: ?*u32, byteLength: ?*u32) callconv(.C) void,
    freeSample: *const fn (sample: ?*AudioSample) callconv(.C) void,
    getLength: *const fn (sample: ?*AudioSample) callconv(.C) f32,
};

pub const PlaydateSoundSampleplayer = extern struct {
    newPlayer: *const fn () callconv(.C) ?*SamplePlayer,
    freePlayer: *const fn (?*SamplePlayer) callconv(.C) void,
    setSample: *const fn (player: ?*SamplePlayer, sample: ?*AudioSample) callconv(.C) void,
    play: *const fn (player: ?*SamplePlayer, repeat: c_int, rate: f32) callconv(.C) c_int,
    isPlaying: *const fn (player: ?*SamplePlayer) callconv(.C) c_int,
    stop: *const fn (player: ?*SamplePlayer) callconv(.C) void,
    setVolume: *const fn (player: ?*SamplePlayer, left: f32, right: f32) callconv(.C) void,
    getVolume: *const fn (player: ?*SamplePlayer, left: ?*f32, right: ?*f32) callconv(.C) void,
    getLength: *const fn (player: ?*SamplePlayer) callconv(.C) f32,
    setOffset: *const fn (player: ?*SamplePlayer, offset: f32) callconv(.C) void,
    setRate: *const fn (player: ?*SamplePlayer, rate: f32) callconv(.C) void,
    setPlayRange: *const fn (player: ?*SamplePlayer, start: c_int, end: c_int) callconv(.C) void,
    setFinishCallback: *const fn (player: ?*SamplePlayer, callback: ?SndCallbackProc) callconv(.C) void,
    setLoopCallback: *const fn (player: ?*SamplePlayer, callback: ?SndCallbackProc) callconv(.C) void,
    getOffset: *const fn (player: ?*SamplePlayer) callconv(.C) f32,
    getRate: *const fn (player: ?*SamplePlayer) callconv(.C) f32,
    setPaused: *const fn (player: ?*SamplePlayer, flag: c_int) callconv(.C) void,
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

    // 1.13
    getEnvelope: *const fn (synth: ?*PDSynth) callconv(.C) ?*PDSynthEnvelope, // synth keeps ownership--don't free this!
};

pub const SequenceTrack = opaque {};
pub const SoundSequence = opaque {};
pub const SequenceFinishedCallback = *const fn (seq: ?*SoundSequence, userdata: ?*anyopaque) callconv(.C) void;

pub const PlaydateSoundSequence = extern struct {
    newSequence: *const fn () callconv(.C) ?*SoundSequence,
    freeSequence: *const fn (sequence: ?*SoundSequence) callconv(.C) void,

    loadMidiFile: *const fn (seq: ?*SoundSequence, path: [*c]const u8) callconv(.C) c_int,
    getTime: *const fn (seq: ?*SoundSequence) callconv(.C) u32,
    setTime: *const fn (seq: ?*SoundSequence, time: u32) callconv(.C) void,
    setLoops: *const fn (seq: ?*SoundSequence, loopstart: c_int, loopend: c_int, loops: c_int) callconv(.C) void,
    getTempo: *const fn (seq: ?*SoundSequence) callconv(.C) c_int,
    setTempo: *const fn (seq: ?*SoundSequence, stepsPerSecond: c_int) callconv(.C) void,
    getTrackCount: *const fn (seq: ?*SoundSequence) callconv(.C) c_int,
    addTrack: *const fn (seq: ?*SoundSequence) callconv(.C) ?*SequenceTrack,
    getTrackAtIndex: *const fn (seq: ?*SoundSequence, track: c_uint) callconv(.C) ?*SequenceTrack,
    setTrackAtIndex: *const fn (seq: ?*SoundSequence, ?*SequenceTrack, idx: c_uint) callconv(.C) void,
    allNotesOff: *const fn (seq: ?*SoundSequence) callconv(.C) void,

    // 1.1
    isPlaying: *const fn (seq: ?*SoundSequence) callconv(.C) c_int,
    getLength: *const fn (seq: ?*SoundSequence) callconv(.C) u32,
    play: *const fn (seq: ?*SoundSequence, finishCallback: SequenceFinishedCallback, userdata: ?*anyopaque) callconv(.C) void,
    stop: *const fn (seq: ?*SoundSequence) callconv(.C) void,
    getCurrentStep: *const fn (seq: ?*SoundSequence, timeOffset: ?*c_int) callconv(.C) c_int,
    setCurrentStep: *const fn (seq: ?*SoundSequence, step: c_int, timeOffset: c_int, playNotes: c_int) callconv(.C) void,
};

pub const EffectProc = *const fn (e: ?*SoundEffect, left: [*c]i32, right: [*c]i32, nsamples: c_int, bufactive: c_int) callconv(.C) c_int;

pub const PlaydateSoundEffect = extern struct {
    newEffect: *const fn (proc: ?*const EffectProc, userdata: ?*anyopaque) callconv(.C) ?*SoundEffect,
    freeEffect: *const fn (effect: ?*SoundEffect) callconv(.C) void,

    setMix: *const fn (effect: ?*SoundEffect, level: f32) callconv(.C) void,
    setMixModulator: *const fn (effect: ?*SoundEffect, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getMixModulator: *const fn (effect: ?*SoundEffect) callconv(.C) ?*PDSynthSignalValue,

    setUserdata: *const fn (effect: ?*SoundEffect, userdata: ?*anyopaque) callconv(.C) void,
    getUserdata: *const fn (effect: ?*SoundEffect) callconv(.C) ?*anyopaque,

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
    newLFO: *const fn (LFOType) callconv(.C) ?*PDSynthLFO,
    freeLFO: *const fn (lfo: ?*PDSynthLFO) callconv(.C) void,

    setType: *const fn (lfo: ?*PDSynthLFO, type: LFOType) callconv(.C) void,
    setRate: *const fn (lfo: ?*PDSynthLFO, rate: f32) callconv(.C) void,
    setPhase: *const fn (lfo: ?*PDSynthLFO, phase: f32) callconv(.C) void,
    setCenter: *const fn (lfo: ?*PDSynthLFO, center: f32) callconv(.C) void,
    setDepth: *const fn (lfo: ?*PDSynthLFO, depth: f32) callconv(.C) void,
    setArpeggiation: *const fn (lfo: ?*PDSynthLFO, nSteps: c_int, steps: [*c]f32) callconv(.C) void,
    setFunction: *const fn (lfo: ?*PDSynthLFO, lfoFunc: *const fn (lfo: ?*PDSynthLFO, userdata: ?*anyopaque) callconv(.C) f32, userdata: ?*anyopaque, interpolate: c_int) callconv(.C) void,
    setDelay: *const fn (lfo: ?*PDSynthLFO, holdoff: f32, ramptime: f32) callconv(.C) void,
    setRetrigger: *const fn (lfo: ?*PDSynthLFO, flag: c_int) callconv(.C) void,

    getValue: *const fn (lfo: ?*PDSynthLFO) callconv(.C) f32,

    // 1.10
    setGlobal: *const fn (lfo: ?*PDSynthLFO, global: c_int) callconv(.C) void,
};

pub const PDSynthEnvelope = opaque {};
pub const PlaydateSoundEnvelope = extern struct {
    newEnvelope: *const fn (attack: f32, decay: f32, sustain: f32, release: f32) callconv(.C) ?*PDSynthEnvelope,
    freeEnvelope: *const fn (env: ?*PDSynthEnvelope) callconv(.C) void,

    setAttack: *const fn (env: ?*PDSynthEnvelope, attack: f32) callconv(.C) void,
    setDecay: *const fn (env: ?*PDSynthEnvelope, decay: f32) callconv(.C) void,
    setSustain: *const fn (env: ?*PDSynthEnvelope, sustain: f32) callconv(.C) void,
    setRelease: *const fn (env: ?*PDSynthEnvelope, release: f32) callconv(.C) void,

    setLegato: *const fn (env: ?*PDSynthEnvelope, flag: c_int) callconv(.C) void,
    setRetrigger: *const fn (env: ?*PDSynthEnvelope, flag: c_int) callconv(.C) void,

    getValue: *const fn (env: ?*PDSynthEnvelope) callconv(.C) f32,

    // 1.13
    setCurvature: *const fn (env: ?*PDSynthEnvelope, amount: f32) callconv(.C) void,
    setVelocitySensitivity: *const fn (env: ?*PDSynthEnvelope, velsens: f32) callconv(.C) void,
    setRateScaling: *const fn (env: ?*PDSynthEnvelope, scaling: f32, start: MIDINote, end: MIDINote) callconv(.C) void,
};

pub const PlaydateSoundSource = extern struct {
    setVolume: *const fn (c: ?*SoundSource, lvol: f32, rvol: f32) callconv(.C) void,
    getVolume: *const fn (c: ?*SoundSource, outl: ?*f32, outr: ?*f32) callconv(.C) void,
    isPlaying: *const fn (c: ?*SoundSource) callconv(.C) c_int,
    setFinishCallback: *const fn (c: ?*SoundSource, SndCallbackProc) callconv(.C) void,
};

pub const ControlSignal = opaque {};
pub const PlaydateControlSignal = extern struct {
    newSignal: *const fn () callconv(.C) ?*ControlSignal,
    freeSignal: *const fn (signal: ?*ControlSignal) callconv(.C) void,
    clearEvents: *const fn (control: ?*ControlSignal) callconv(.C) void,
    addEvent: *const fn (control: ?*ControlSignal, step: c_int, value: f32, c_int) callconv(.C) void,
    removeEvent: *const fn (control: ?*ControlSignal, step: c_int) callconv(.C) void,
    getMIDIControllerNumber: *const fn (control: ?*ControlSignal) callconv(.C) c_int,
};

pub const PlaydateSoundTrack = extern struct {
    newTrack: *const fn () callconv(.C) ?*SequenceTrack,
    freeTrack: *const fn (track: ?*SequenceTrack) callconv(.C) void,

    setInstrument: *const fn (track: ?*SequenceTrack, inst: ?*PDSynthInstrument) callconv(.C) void,
    getInstrument: *const fn (track: ?*SequenceTrack) callconv(.C) ?*PDSynthInstrument,

    addNoteEvent: *const fn (track: ?*SequenceTrack, step: u32, len: u32, note: MIDINote, velocity: f32) callconv(.C) void,
    removeNoteEvent: *const fn (track: ?*SequenceTrack, step: u32, note: MIDINote) callconv(.C) void,
    clearNotes: *const fn (track: ?*SequenceTrack) callconv(.C) void,

    getControlSignalCount: *const fn (track: ?*SequenceTrack) callconv(.C) c_int,
    getControlSignal: *const fn (track: ?*SequenceTrack, idx: c_int) callconv(.C) ?*ControlSignal,
    clearControlEvents: *const fn (track: ?*SequenceTrack) callconv(.C) void,

    getPolyphony: *const fn (track: ?*SequenceTrack) callconv(.C) c_int,
    activeVoiceCount: *const fn (track: ?*SequenceTrack) callconv(.C) c_int,

    setMuted: *const fn (track: ?*SequenceTrack, mute: c_int) callconv(.C) void,

    // 1.1
    getLength: *const fn (track: ?*SequenceTrack) callconv(.C) u32,
    getIndexForStep: *const fn (track: ?*SequenceTrack, step: u32) callconv(.C) c_int,
    getNoteAtIndex: *const fn (track: ?*SequenceTrack, index: c_int, outSteo: ?*u32, outLen: ?*u32, outeNote: ?*MIDINote, outVelocity: ?*f32) callconv(.C) c_int,

    //1.10
    getSignalForController: *const fn (track: ?*SequenceTrack, controller: c_int, create: c_int) callconv(.C) ?*ControlSignal,
};

pub const PDSynthInstrument = SoundSource;
pub const PlaydateSoundInstrument = extern struct {
    newInstrument: *const fn () callconv(.C) ?*PDSynthInstrument,
    freeInstrument: *const fn (inst: ?*PDSynthInstrument) callconv(.C) void,
    addVoice: *const fn (inst: ?*PDSynthInstrument, synth: ?*PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: f32) callconv(.C) c_int,
    playNote: *const fn (inst: ?*PDSynthInstrument, frequency: f32, vel: f32, len: f32, when: u32) callconv(.C) ?*PDSynth,
    playMIDINote: *const fn (inst: ?*PDSynthInstrument, note: MIDINote, vel: f32, len: f32, when: u32) callconv(.C) ?*PDSynth,
    setPitchBend: *const fn (inst: ?*PDSynthInstrument, bend: f32) callconv(.C) void,
    setPitchBendRange: *const fn (inst: ?*PDSynthInstrument, halfSteps: f32) callconv(.C) void,
    setTranspose: *const fn (inst: ?*PDSynthInstrument, halfSteps: f32) callconv(.C) void,
    noteOff: *const fn (inst: ?*PDSynthInstrument, note: MIDINote, when: u32) callconv(.C) void,
    allNotesOff: *const fn (inst: ?*PDSynthInstrument, when: u32) callconv(.C) void,
    setVolume: *const fn (inst: ?*PDSynthInstrument, left: f32, right: f32) callconv(.C) void,
    getVolume: *const fn (inst: ?*PDSynthInstrument, left: ?*f32, right: ?*f32) callconv(.C) void,
    activeVoiceCount: *const fn (inst: ?*PDSynthInstrument) callconv(.C) c_int,
};

pub const PDSynthSignal = opaque {};
pub const SignalStepFunc = *const fn (userdata: ?*anyopaque, ioframes: [*c]c_int, ifval: ?*f32) callconv(.C) f32;
// len = -1 for indefinite
pub const SignalNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, vel: f32, len: f32) callconv(.C) void;
// ended = 0 for note release, = 1 when note stops playing
pub const SignalNoteOffFunc = *const fn (userdata: ?*anyopaque, stopped: c_int, offset: c_int) callconv(.C) void;
pub const SignalDeallocFunc = *const fn (userdata: ?*anyopaque) callconv(.C) void;
pub const PlaydateSoundSignal = struct {
    newSignal: *const fn (step: SignalStepFunc, noteOn: SignalNoteOnFunc, noteOff: SignalNoteOffFunc, dealloc: SignalDeallocFunc, userdata: ?*anyopaque) callconv(.C) ?*PDSynthSignal,
    freeSignal: *const fn (signal: ?*PDSynthSignal) callconv(.C) void,
    getValue: *const fn (signal: ?*PDSynthSignal) callconv(.C) f32,
    setValueScale: *const fn (signal: ?*PDSynthSignal, scale: f32) callconv(.C) void,
    setValueOffset: *const fn (signal: ?*PDSynthSignal, offset: f32) callconv(.C) void,
};

// EFFECTS

// A SoundEffect processes the output of a channel's SoundSources

const TwoPoleFilter = SoundEffect;
const TwoPoleFilterType = enum(c_int) {
    FilterTypeLowPass,
    FilterTypeHighPass,
    FilterTypeBandPass,
    FilterTypeNotch,
    FilterTypePEQ,
    FilterTypeLowShelf,
    FilterTypeHighShelf,
};
const PlaydateSoundEffectTwopolefilter = extern struct {
    newFilter: *const fn () callconv(.C) ?*TwoPoleFilter,
    freeFilter: *const fn (filter: ?*TwoPoleFilter) callconv(.C) void,
    setType: *const fn (filter: ?*TwoPoleFilter, type: TwoPoleFilterType) callconv(.C) void,
    setFrequency: *const fn (filter: ?*TwoPoleFilter, frequency: f32) callconv(.C) void,
    setFrequencyModulator: *const fn (filter: ?*TwoPoleFilter, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getFrequencyModulator: *const fn (filter: ?*TwoPoleFilter) callconv(.C) ?*PDSynthSignalValue,
    setGain: *const fn (filter: ?*TwoPoleFilter, f32) callconv(.C) void,
    setResonance: *const fn (filter: ?*TwoPoleFilter, f32) callconv(.C) void,
    setResonanceModulator: *const fn (filter: ?*TwoPoleFilter, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getResonanceModulator: *const fn (filter: ?*TwoPoleFilter) callconv(.C) ?*PDSynthSignalValue,
};

pub const OnePoleFilter = SoundEffect;
pub const PlaydateSoundEffectOnepolefilter = extern struct {
    newFilter: *const fn () callconv(.C) ?*OnePoleFilter,
    freeFilter: *const fn (filter: ?*OnePoleFilter) callconv(.C) void,
    setParameter: *const fn (filter: ?*OnePoleFilter, parameter: f32) callconv(.C) void,
    setParameterModulator: *const fn (filter: ?*OnePoleFilter, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getParameterModulator: *const fn (filter: ?*OnePoleFilter) callconv(.C) ?*PDSynthSignalValue,
};

pub const BitCrusher = SoundEffect;
pub const PlaydateSoundEffectBitcrusher = extern struct {
    newBitCrusher: *const fn () callconv(.C) ?*BitCrusher,
    freeBitCrusher: *const fn (filter: ?*BitCrusher) callconv(.C) void,
    setAmount: *const fn (filter: ?*BitCrusher, amount: f32) callconv(.C) void,
    setAmountModulator: *const fn (filter: ?*BitCrusher, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getAmountModulator: *const fn (filter: ?*BitCrusher) callconv(.C) ?*PDSynthSignalValue,
    setUndersampling: *const fn (filter: ?*BitCrusher, undersampling: f32) callconv(.C) void,
    setUndersampleModulator: *const fn (filter: ?*BitCrusher, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getUndersampleModulator: *const fn (filter: ?*BitCrusher) callconv(.C) ?*PDSynthSignalValue,
};

pub const RingModulator = SoundEffect;
pub const PlaydateSoundEffectRingmodulator = extern struct {
    newRingmod: *const fn () callconv(.C) ?*RingModulator,
    freeRingmod: *const fn (filter: ?*RingModulator) callconv(.C) void,
    setFrequency: *const fn (filter: ?*RingModulator, frequency: f32) callconv(.C) void,
    setFrequencyModulator: *const fn (filter: ?*RingModulator, signal: ?*PDSynthSignalValue) callconv(.C) void,
    getFrequencyModulator: *const fn (filter: ?*RingModulator) callconv(.C) ?*PDSynthSignalValue,
};

pub const DelayLine = SoundEffect;
pub const DelayLineTap = SoundSource;
pub const PlaydateSoundEffectDelayline = extern struct {
    newDelayLine: *const fn (length: c_int, stereo: c_int) callconv(.C) ?*DelayLine,
    freeDelayLine: *const fn (filter: ?*DelayLine) callconv(.C) void,
    setLength: *const fn (filter: ?*DelayLine, frames: c_int) callconv(.C) void,
    setFeedback: *const fn (filter: ?*DelayLine, fb: f32) callconv(.C) void,
    addTap: *const fn (filter: ?*DelayLine, delay: c_int) callconv(.C) ?*DelayLineTap,

    // note that DelayLineTap is a SoundSource, not a SoundEffect
    freeTap: *const fn (tap: ?*DelayLineTap) callconv(.C) void,
    setTapDelay: *const fn (t: ?*DelayLineTap, frames: c_int) callconv(.C) void,
    setTapDelayModulator: *const fn (t: ?*DelayLineTap, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getTapDelayModulator: *const fn (t: ?*DelayLineTap) callconv(.C) ?*PDSynthSignalValue,
    setTapChannelsFlipped: *const fn (t: ?*DelayLineTap, flip: c_int) callconv(.C) void,
};

pub const Overdrive = SoundEffect;
pub const PlaydateSoundEffectOverdrive = extern struct {
    newOverdrive: *const fn () callconv(.C) ?*Overdrive,
    freeOverdrive: *const fn (filter: ?*Overdrive) callconv(.C) void,
    setGain: *const fn (o: ?*Overdrive, gain: f32) callconv(.C) void,
    setLimit: *const fn (o: ?*Overdrive, limit: f32) callconv(.C) void,
    setLimitModulator: *const fn (o: ?*Overdrive, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getLimitModulator: *const fn (o: ?*Overdrive) callconv(.C) ?*PDSynthSignalValue,
    setOffset: *const fn (o: ?*Overdrive, offset: f32) callconv(.C) void,
    setOffsetModulator: *const fn (o: ?*Overdrive, mod: ?*PDSynthSignalValue) callconv(.C) void,
    getOffsetModulator: *const fn (o: ?*Overdrive) callconv(.C) ?*PDSynthSignalValue,
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

pub fn PDRectMake(x: f32, y: f32, width: f32, height: f32) callconv(.C) PDRect {
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

pub const LCDSpriteDrawFunction = ?*const fn (sprite: ?*LCDSprite, bounds: PDRect, drawrect: PDRect) callconv(.C) void;
pub const LCDSpriteUpdateFunction = ?*const fn (sprite: ?*LCDSprite) callconv(.C) void;
pub const LCDSpriteCollisionFilterProc = ?*const fn (sprite: ?*LCDSprite, other: ?*LCDSprite) callconv(.C) SpriteCollisionResponseType;

pub const PlaydateSprite = extern struct {
    setAlwaysRedraw: *const fn (flag: c_int) callconv(.C) void,
    addDirtyRect: *const fn (dirtyRect: LCDRect) callconv(.C) void,
    drawSprites: *const fn () callconv(.C) void,
    updateAndDrawSprites: *const fn () callconv(.C) void,

    newSprite: *const fn () callconv(.C) ?*LCDSprite,
    freeSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    copy: *const fn (sprite: ?*LCDSprite) callconv(.C) ?*LCDSprite,

    addSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    removeSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    removeSprites: *const fn (sprite: [*c]?*LCDSprite, count: c_int) callconv(.C) void,
    removeAllSprites: *const fn () callconv(.C) void,
    getSpriteCount: *const fn () callconv(.C) c_int,

    setBounds: *const fn (sprite: ?*LCDSprite, bounds: PDRect) callconv(.C) void,
    getBounds: *const fn (sprite: ?*LCDSprite) callconv(.C) PDRect,
    moveTo: *const fn (sprite: ?*LCDSprite, x: f32, y: f32) callconv(.C) void,
    moveBy: *const fn (sprite: ?*LCDSprite, dx: f32, dy: f32) callconv(.C) void,

    setImage: *const fn (sprite: ?*LCDSprite, image: ?*LCDBitmap, flip: LCDBitmapFlip) callconv(.C) void,
    getImage: *const fn (sprite: ?*LCDSprite) callconv(.C) ?*LCDBitmap,
    setSize: *const fn (s: ?*LCDSprite, width: f32, height: f32) callconv(.C) void,
    setZIndex: *const fn (s: ?*LCDSprite, zIndex: i16) callconv(.C) void,
    getZIndex: *const fn (sprite: ?*LCDSprite) callconv(.C) i16,

    setDrawMode: *const fn (sprite: ?*LCDSprite, mode: LCDBitmapDrawMode) callconv(.C) void,
    setImageFlip: *const fn (sprite: ?*LCDSprite, flip: LCDBitmapFlip) callconv(.C) void,
    getImageFlip: *const fn (sprite: ?*LCDSprite) callconv(.C) LCDBitmapFlip,
    setStencil: *const fn (sprite: ?*LCDSprite, mode: ?*LCDBitmap) callconv(.C) void, // deprecated in favor of setStencilImage()

    setClipRect: *const fn (sprite: ?*LCDSprite, clipRect: LCDRect) callconv(.C) void,
    clearClipRect: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    setClipRectsInRange: *const fn (clipRect: LCDRect, startZ: c_int, endZ: c_int) callconv(.C) void,
    clearClipRectsInRange: *const fn (startZ: c_int, endZ: c_int) callconv(.C) void,

    setUpdatesEnabled: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    updatesEnabled: *const fn (sprite: ?*LCDSprite) callconv(.C) c_int,
    setCollisionsEnabled: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    collisionsEnabled: *const fn (sprite: ?*LCDSprite) callconv(.C) c_int,
    setVisible: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    isVisible: *const fn (sprite: ?*LCDSprite) callconv(.C) c_int,
    setOpaque: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    markDirty: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    setTag: *const fn (sprite: ?*LCDSprite, tag: u8) callconv(.C) void,
    getTag: *const fn (sprite: ?*LCDSprite) callconv(.C) u8,

    setIgnoresDrawOffset: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,

    setUpdateFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteUpdateFunction) callconv(.C) void,
    setDrawFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteDrawFunction) callconv(.C) void,

    getPosition: *const fn (s: ?*LCDSprite, x: ?*f32, y: ?*f32) callconv(.C) void,

    // Collisions
    resetCollisionWorld: *const fn () callconv(.C) void,

    setCollideRect: *const fn (sprite: ?*LCDSprite, collideRect: PDRect) callconv(.C) void,
    getCollideRect: *const fn (sprite: ?*LCDSprite) callconv(.C) PDRect,
    clearCollideRect: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    // caller is responsible for freeing the returned array for all collision methods
    setCollisionResponseFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteCollisionFilterProc) callconv(.C) void,
    checkCollisions: *const fn (sprite: ?*LCDSprite, goalX: f32, goalY: f32, actualX: ?*f32, actualY: ?*f32, len: ?*c_int) callconv(.C) [*c]SpriteCollisionInfo, // access results using const info = &results[i];
    moveWithCollisions: *const fn (sprite: ?*LCDSprite, goalX: f32, goalY: f32, actualX: ?*f32, actualY: ?*f32, len: ?*c_int) callconv(.C) [*c]SpriteCollisionInfo,
    querySpritesAtPoint: *const fn (x: f32, y: f32, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    querySpritesInRect: *const fn (x: f32, y: f32, width: f32, height: f32, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    querySpritesAlongLine: *const fn (x1: f32, y1: f32, x2: f32, y2: f32, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    querySpriteInfoAlongLine: *const fn (x1: f32, y1: f32, x2: f32, y2: f32, len: ?*c_int) callconv(.C) [*c]SpriteQueryInfo, // access results using const info = &results[i];
    overlappingSprites: *const fn (sprite: ?*LCDSprite, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    allOverlappingSprites: *const fn (len: ?*c_int) callconv(.C) [*c]?*LCDSprite,

    // added in 1.7
    setStencilPattern: *const fn (sprite: ?*LCDSprite, pattern: [*c]u8) callconv(.C) void, //pattern is 8 bytes
    clearStencil: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    setUserdata: *const fn (sprite: ?*LCDSprite, userdata: ?*anyopaque) callconv(.C) void,
    getUserdata: *const fn (sprite: ?*LCDSprite) callconv(.C) ?*anyopaque,

    // added in 1.10
    setStencilImage: *const fn (sprite: ?*LCDSprite, stencil: ?*LCDBitmap, tile: c_int) callconv(.C) void,
};

////////Lua///////
pub const LuaState = ?*anyopaque;
pub const LuaCFunction = ?*const fn (state: ?*LuaState) callconv(.C) c_int;
pub const LuaUDObject = opaque {};

//literal value
pub const LValType = enum(c_int) {
    Int = 0,
    Float = 1,
    Str = 2,
};
pub const LuaReg = extern struct {
    name: [*c]const u8,
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
    name: [*c]const u8,
    type: LValType,
    v: extern union {
        intval: c_uint,
        floatval: f32,
        strval: [*c]const u8,
    },
};
pub const PlaydateLua = extern struct {
    // these two return 1 on success, else 0 with an error message in outErr
    addFunction: *const fn (f: LuaCFunction, name: [*c]const u8, outErr: ?*[*c]const u8) callconv(.C) c_int,
    registerClass: *const fn (name: [*c]const u8, reg: ?*const LuaReg, vals: [*c]const LuaVal, isstatic: c_int, outErr: ?*[*c]const u8) callconv(.C) c_int,

    pushFunction: *const fn (f: LuaCFunction) callconv(.C) void,
    indexMetatable: *const fn () callconv(.C) c_int,

    stop: *const fn () callconv(.C) void,
    start: *const fn () callconv(.C) void,

    // stack operations
    getArgCount: *const fn () callconv(.C) c_int,
    getArgType: *const fn (pos: c_int, outClass: ?*[*c]const u8) callconv(.C) LuaType,

    argIsNil: *const fn (pos: c_int) callconv(.C) c_int,
    getArgBool: *const fn (pos: c_int) callconv(.C) c_int,
    getArgInt: *const fn (pos: c_int) callconv(.C) c_int,
    getArgFloat: *const fn (pos: c_int) callconv(.C) f32,
    getArgString: *const fn (pos: c_int) callconv(.C) [*c]const u8,
    getArgBytes: *const fn (pos: c_int, outlen: ?*usize) callconv(.C) [*c]const u8,
    getArgObject: *const fn (pos: c_int, type: ?*i8, ?*?*LuaUDObject) callconv(.C) ?*anyopaque,

    getBitmap: *const fn (c_int) callconv(.C) ?*LCDBitmap,
    getSprite: *const fn (c_int) callconv(.C) ?*LCDSprite,

    // for returning values back to Lua
    pushNil: *const fn () callconv(.C) void,
    pushBool: *const fn (val: c_int) callconv(.C) void,
    pushInt: *const fn (val: c_int) callconv(.C) void,
    pushFloat: *const fn (val: f32) callconv(.C) void,
    pushString: *const fn (str: [*c]const u8) callconv(.C) void,
    pushBytes: *const fn (str: [*c]const u8, len: usize) callconv(.C) void,
    pushBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.C) void,
    pushSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    pushObject: *const fn (obj: ?*anyopaque, type: ?*i8, nValues: c_int) callconv(.C) ?*LuaUDObject,
    retainObject: *const fn (obj: ?*LuaUDObject) callconv(.C) ?*LuaUDObject,
    releaseObject: *const fn (obj: ?*LuaUDObject) callconv(.C) void,

    setObjectValue: *const fn (obj: ?*LuaUDObject, slot: c_int) callconv(.C) void,
    getObjectValue: *const fn (obj: ?*LuaUDObject, slot: c_int) callconv(.C) c_int,

    // calling lua from C has some overhead. use sparingly!
    callFunction_deprecated: *const fn (name: [*c]const u8, nargs: c_int) callconv(.C) void,
    callFunction: *const fn (name: [*c]const u8, nargs: c_int, outerr: ?*[*c]const u8) callconv(.C) c_int,
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
    decodeError: *const fn (decoder: ?*JSONDecoder, @"error": [*c]const u8, linenum: c_int) callconv(.C) void,

    // the following functions are each optional
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) void,
    shouldDecodeTableValueForKey: ?*const fn (decoder: ?*JSONDecoder, key: [*c]const u8) callconv(.C) c_int,
    didDecodeTableValue: ?*const fn (decoder: ?*JSONDecoder, key: [*c]const u8, value: JSONValue) callconv(.C) void,
    shouldDecodeArrayValueAtIndex: ?*const fn (decoder: ?*JSONDecoder, pos: c_int) callconv(.C) c_int,
    didDecodeArrayValue: ?*const fn (decoder: ?*JSONDecoder, pos: c_int, value: JSONValue) callconv(.C) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) ?*anyopaque,

    userdata: ?*anyopaque,
    returnString: c_int, // when set, the decoder skips parsing and returns the current subtree as a string
    path: [*c]const u8, // updated during parsing, reflects current position in tree
};

// convenience functions for setting up a table-only or array-only decoder

pub inline fn json_setTableDecode(
    decoder: ?*JSONDecoder,
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) void,
    didDecodeTableValue: ?*const fn (decoder: ?*JSONDecoder, key: [*c]const u8, value: JSONValue) callconv(.C) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, name: JSONValueType) callconv(.C) ?*anyopaque,
) void {
    decoder.?.didDecodeTableValue = didDecodeTableValue;
    decoder.?.didDecodeArrayValue = null;
    decoder.?.willDecodeSublist = willDecodeSublist;
    decoder.?.didDecodeSublist = didDecodeSublist;
}

pub inline fn json_setArrayDecode(
    decoder: ?*JSONDecoder,
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) void,
    didDecodeArrayValue: ?*const fn (decoder: ?*JSONDecoder, pos: c_int, value: JSONValue) callconv(.C) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) ?*anyopaque,
) void {
    decoder.?.didDecodeTableValue = null;
    decoder.?.didDecodeArrayValue = didDecodeArrayValue;
    decoder.?.willDecodeSublist = willDecodeSublist;
    decoder.?.didDecodeSublist = didDecodeSublist;
}

pub const JSONReader = extern struct {
    read: *const fn (userdata: ?*anyopaque, buf: [*c]u8, bufsize: c_int) callconv(.C) c_int,
    userdata: ?*anyopaque,
};
pub const writeFunc = *const fn (userdata: ?*anyopaque, str: [*c]const u8, len: c_int) callconv(.C) void;

pub const JSONEncoder = extern struct {
    writeStringFunc: writeFunc,
    userdata: ?*anyopaque,

    state: u32, //this is pretty, startedTable, startedArray and depth bitfields combined

    startArray: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    addArrayMember: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    endArray: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    startTable: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    addTableMember: *const fn (encoder: ?*JSONEncoder, name: [*c]const u8, len: c_int) callconv(.C) void,
    endTable: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeNull: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeFalse: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeTrue: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeInt: *const fn (encoder: ?*JSONEncoder, num: c_int) callconv(.C) void,
    writeDouble: *const fn (encoder: ?*JSONEncoder, num: f64) callconv(.C) void,
    writeString: *const fn (encoder: ?*JSONEncoder, str: [*c]const u8, len: c_int) callconv(.C) void,
};

pub const PlaydateJSON = extern struct {
    initEncoder: *const fn (encoder: ?*JSONEncoder, write: writeFunc, userdata: ?*anyopaque, pretty: c_int) callconv(.C) void,

    decode: *const fn (functions: ?*JSONDecoder, reader: JSONReader, outval: ?*JSONValue) callconv(.C) c_int,
    decodeString: *const fn (functions: ?*JSONDecoder, jsonString: [*c]const u8, outval: ?*JSONValue) callconv(.C) c_int,
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
pub const AddScoreCallback = ?*const fn (score: ?*PDScore, errorMessage: [*c]const u8) callconv(.C) void;
pub const PersonalBestCallback = ?*const fn (score: ?*PDScore, errorMessage: [*c]const u8) callconv(.C) void;
pub const BoardsListCallback = ?*const fn (boards: ?*PDBoardsList, errorMessage: [*c]const u8) callconv(.C) void;
pub const ScoresCallback = ?*const fn (scores: ?*PDScoresList, errorMessage: [*c]const u8) callconv(.C) void;

pub const PlaydateScoreboards = extern struct {
    addScore: *const fn (boardId: [*c]const u8, value: u32, callback: AddScoreCallback) callconv(.C) c_int,
    getPersonalBest: *const fn (boardId: [*c]const u8, callback: PersonalBestCallback) callconv(.C) c_int,
    freeScore: *const fn (score: ?*PDScore) callconv(.C) void,

    getScoreboards: *const fn (callback: BoardsListCallback) callconv(.C) c_int,
    freeBoardsList: *const fn (boards: ?*PDBoardsList) callconv(.C) void,

    getScores: *const fn (boardId: [*c]const u8, callback: ScoresCallback) callconv(.C) c_int,
    freeScoresList: *const fn (scores: ?*PDScoresList) callconv(.C) void,
};
