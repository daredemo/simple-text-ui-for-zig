const std = @import("std");

const ChRead = @import("CharReader.zig");
const Term = @import("ansi_terminal.zig");
const libdef = @import("definitions.zig");
const string_stuff = @import("StringStuff.zig");
const Border = @import("Border.zig");
const RGB = @import("Color.zig").RGB;
const ColorB = @import("Color.zig").ColorB;
const ColorF = @import("Color.zig").ColorF;
const ColorBU = @import("Color.zig").ColorBU;
const ColorFU = @import("Color.zig").ColorFU;
const ColorStyle = @import("Color.zig").ColorStyle;
const ColorModes = @import("Color.zig").ColorModes;
const TextLine = @import("TextLine.zig").TextLine;
const Panel = @import("Panel.zig").Panel;
const Layout = @import("Panel.zig").Layout;
const RenderText = @import("Panel.zig").RenderText;
const TitlePosition = @import("Panel.zig").PositionTB;
const StrAU = string_stuff.Alignment;
const stringAlign = string_stuff.stringAlign;

const BufWriter = @import(
    "SimpleBufferedWriter.zig",
).SimpleBufferedWriter;

pub fn main() !void {
    var buf_writer = BufWriter{};
    defer _ = buf_writer.flush() catch unreachable;
    libdef.handleSigwinch(0);
    libdef.setSignal();
    _ = Term.saveTerminalState(&buf_writer);
    defer {
        _ = Term.restoreTerminalState(&buf_writer);
    }
    const old_terminal = libdef.saveTerminalSettings();
    var new_terminal = libdef.saveTerminalSettings();
    defer libdef.restoreTerminalSettings(old_terminal);
    libdef.disableEchoAndCanonicalMode(&new_terminal);
    _ = Term.disableCursor(&buf_writer);
    defer {
        _ = Term.enableCursor(&buf_writer);
    }
    defer {
        _ = Term.setColorStyle(
            &buf_writer,
            ColorStyle{
                .bg = null,
                .fg = null,
                .modes = ColorModes{
                    .Reset = true,
                },
            },
        );
    }
    _ = Term.clearScreen(&buf_writer);
    _ = buf_writer.flush() catch unreachable;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();
    // PANEL: ROOT
    const panel_root = Panel.initRoot(
        "FULL",
        &libdef.win_width,
        &libdef.win_height,
        Layout.Horizontal,
        &allocator,
        &buf_writer,
    ).setBorder(null);
    defer _ = allocator.destroy(panel_root);
    defer _ = panel_root.deinit(&allocator);
    // PANEL: MAIN
    const panel_main = Panel.init(
        "INFO",
        panel_root,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_main);
    defer _ = panel_main.deinit(&allocator);
    const border_1 = Border.Border.init(
        &allocator,
    ).setBorderStyle(
        Border.BorderStyle.LightRound,
    ).setColor(
        ColorStyle.init(
            null,
            null,
            // ColorF.initValue(22),
            ColorModes{
                // .Italic = true,
                .Bold = true,
            },
        ),
    );
    defer _ = allocator.destroy(border_1);
    _ = panel_main.setBorder(
        border_1.*,
    ).titleLocation(
        StrAU.Center,
        TitlePosition.Top,
    );
    // PANEL: VOID LEFT OF MAIN
    const panel_main_void_l = Panel.init(
        "VOID L",
        panel_root,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_main_void_l);
    defer panel_main_void_l.deinit(&allocator);
    // PANEL: VOID RIGHT OF MAIN
    const panel_main_void_r = Panel.init(
        "VOID R",
        panel_root,
        Layout.Vertical,
        &allocator,
    );
    defer _ = allocator.destroy(panel_main_void_r);
    defer panel_main_void_r.deinit(&allocator);
    _ = panel_main_void_l.setBorder(
        border_1.*,
    ).titleLocation(
        StrAU.Left,
        TitlePosition.Bottom,
    );
    _ = panel_main_void_r.setBorder(
        border_1.*,
    ).titleLocation(
        StrAU.Right,
        TitlePosition.Bottom,
    );
    _ = panel_root.appendChild(
        panel_main_void_l,
        null,
        1.0,
    );
    _ = panel_root.appendChild(
        panel_main,
        30,
        null,
    );
    _ = panel_root.appendChild(
        panel_main_void_r,
        null,
        1.0,
    );
    var the_app = TheApp.init(
        "Threaded App",
        panel_root,
        20,
        15,
        &buf_writer,
    );
    var thread_heartbeat = try std.Thread.spawn(
        .{},
        doAppHeartBeatThread,
        .{
            &the_app,
        },
    );
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(
        .{},
        doAppInputThread,
        .{
            &the_app,
        },
    );
    defer thread_inputs.join();
    _ = Term.setColorB(
        &buf_writer,
        ColorB.initName(
            ColorBU.Reset,
        ),
    );
    _ = buf_writer.flush() catch unreachable;
}

pub fn doAppInputThread(arg: *TheApp) !void {
    try arg.getInputs();
}

pub fn doAppHeartBeatThread(arg: *TheApp) !void {
    try arg.getHeartBeat();
}

const TheApp = struct {
    name: []const u8,
    mutex: std.Thread.Mutex = .{},
    is_running: bool,
    heart_beat: bool,
    width: u8,
    height: u8,
    root_panel: *Panel = undefined,
    writer: *BufWriter = undefined,

    pub fn init(
        the_name: []const u8,
        root_panel: *Panel,
        width: u8,
        height: u8,
        writer: *BufWriter,
    ) TheApp {
        return TheApp{
            .name = the_name,
            .is_running = true,
            .heart_beat = false,
            .width = width,
            .height = height,
            .root_panel = root_panel,
            .writer = writer,
        };
    }

    pub fn getInputs(self: *TheApp) !void {
        var reader = ChRead.CharReader.init();
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            const c = reader.getchar();
            const ch = if (c) |cc| cc else 0;
            switch (ch) {
                'p' => {
                    // _ = Term.eraseCES();
                    // _ = tl_input.textLine("Printing...").draw();
                },
                'r' => {
                    // _ = Term.eraseCES();
                    // _ = tl_input.textLine("Running...").draw();
                },
                9 => {
                    // _ = Term.eraseCES();
                    // _ = tl_input.textLine("TAB").draw();
                },
                10 => {
                    // _ = Term.eraseCES();
                    // _ = tl_input.textLine("ENTER").draw();
                },
                32 => {
                    // _ = Term.eraseCES();
                    // _ = tl_input.textLine("SPACE").draw();
                },
                'q' => {
                    _ = Term.eraseCES(self.writer);
                    self.mutex.lock();
                    defer self.mutex.unlock();
                    self.is_running = false;
                    break;
                },
                33...111 => {
                    //     _ = Term.eraseCES();
                    //     _ = tl_input.textLine(([2]u8{ ch, 0 })[0..]).draw();
                },
                115...126 => {
                    // _ = Term.eraseCES();
                    // _ = tl_input.textLine(([2]u8{ ch, 0 })[0..]).draw();
                },
                27 => {
                    const ch1 = reader.getchar();
                    const cha = if (ch1) |cc| cc else 0;
                    if (cha == '[') {
                        const ch2 = reader.getchar();
                        const chb = if (ch2) |cc| cc else 0;
                        switch (chb) {
                            'A' => {
                                // _ = Term.eraseCES();
                                // _ = tl_input.textLine("Arrow UP").draw();
                            },
                            'B' => {
                                // _ = Term.eraseCES();
                                // _ = tl_input.textLine("Arrow DOWN").draw();
                            },
                            'C' => {
                                // _ = Term.eraseCES();
                                // _ = tl_input.textLine("Arrow RIGHT").draw();
                            },
                            'D' => {
                                // _ = Term.eraseCES();
                                // _ = tl_input.textLine("Arrow LEFT").draw();
                            },
                            else => {},
                        }
                    } else {
                        _ = reader.ungetcLast();
                        // _ = Term.eraseCES();
                        // _ = tl_input.textLine("ESCAPE").draw();
                    }
                },
                else => {},
            }
        }
    }

    pub fn getHeartBeat(self: *TheApp) !void {
        var counter: u8 = 0;
        var tl_heart = TextLine.init(
            self.writer,
            "♥",
        );
        _ = tl_heart.fg(ColorF.initName(ColorFU.Blue)); //.absXY(0, 5);
        var tl_panelinfo = TextLine.init(
            self.writer,
            "q -- quit/exit",
        );
        _ = tl_panelinfo.relativeXY(
            2,
            2,
        );
        // _ = tl_panelinfo.setColor(
        //     ColorStyle.init(
        //         null,
        //         null,
        //         ColorModes{
        //             .Italic = true,
        //         },
        //     ),
        // );
        const child_head = self.root_panel.child_head.?;
        const child_2 = child_head.sibling_next.?;
        _ = tl_heart.parentXY(
            @abs(child_2.anchor_x),
            @abs(child_2.anchor_y),
        ).relativeXY(
            2,
            1,
        );
        _ = tl_panelinfo.parentXY(
            @abs(child_2.anchor_x),
            @abs(child_2.anchor_y),
        );
        var rt1 = RenderText{
            .parent = child_2,
            .text = &tl_heart,
            .next_text = null,
        };
        _ = child_2.appendText(&rt1);
        var rt2 = RenderText{
            .parent = null,
            .text = &tl_panelinfo,
            .next_text = null,
        };
        _ = child_2.appendText(&rt2);
        _ = self.root_panel.draw();
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            _ = self.root_panel.update();
            _ = std.time.sleep(std.time.ns_per_s / 10);
            defer counter = (counter + 1) % 10;
            if (counter == 0) {
                self.heart_beat = !self.heart_beat;
                self.mutex.lock();
                defer self.mutex.unlock();
                if (self.heart_beat) {
                    _ = tl_heart.textLine("♥");
                } else {
                    _ = tl_heart.textLine(" ");
                }
                _ = Term.setColorF(
                    self.writer,
                    ColorF.initName(ColorFU.Default),
                );
            }
            _ = self.root_panel.draw();
            _ = self.writer.flush() catch unreachable;
        }
    }
};
