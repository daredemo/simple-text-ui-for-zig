const std = @import("std");

const ChRead = @import("CharReader.zig");
const Term = @import("ansi_terminal.zig");
// const TLine = @import("TextLine.zig");
const libdef = @import("definitions.zig");
const string_stuff = @import("StringStuff.zig");
const Border = @import("Border.zig");
const RGB = @import("Color.zig").RGB;
const ColorB = @import("Color.zig").ColorB;
const ColorF = @import("Color.zig").ColorF;
const ColorBU = @import("Color.zig").ColorBU;
const ColorFU = @import("Color.zig").ColorFU;
const ColorMU = @import("Color.zig").ColorMU;
const ColorBE = @import("Color.zig").ColorBE;
const ColorFE = @import("Color.zig").ColorFE;
const ColorME = @import("Color.zig").ColorME;
const ColorStype = @import("Color.zig").ColorStyle;
const TextLine = @import("TextLine.zig").TextLine;
const Panel = @import("Panel.zig").Panel;
const Layout = @import("Panel.zig").Layout;
const RenderText = @import("Panel.zig").RenderText;
const TitlePosition = @import("Panel.zig").PositionTB;
const StrAE = string_stuff.AlignmentE;
const StrAU = string_stuff.Alignment;
const string_align = string_stuff.string_align;

const write_out = std.io.getStdOut().writer();

pub fn main() !void {
    libdef.handle_sigwinch(0);
    libdef.set_signal();
    _ = Term.save_terminal_state();
    defer {
        _ = Term.restore_terminal_state();
    }
    const old_terminal = libdef.save_terminal_settings();
    var new_terminal = libdef.save_terminal_settings();
    defer libdef.restore_terminal_settings(old_terminal);
    libdef.disable_echo_and_canonical_mode(&new_terminal);
    _ = Term.disable_cursor();
    defer {
        _ = Term.ensable_cursor();
    }
    defer {
        _ = Term.set_color_mbf(ColorMU{ .Reset = {} }, null, null);
    }
    _ = Term.clear_screen();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();
    // PANEL: ROOT
    const panel_root = Panel.init_root("FULL", &libdef.win_width, &libdef.win_height, Layout.Horizontal, &allocator).set_border(null);
    defer _ = allocator.destroy(panel_root);
    defer _ = panel_root.deinit(&allocator);
    // PANEL: MAIN
    const panel_main = Panel.init("INFO", panel_root, Layout.Vertical, &allocator);
    defer _ = allocator.destroy(panel_main);
    defer _ = panel_main.deinit(&allocator);
    const border_1 = Border.Border.init(&allocator).set_border_style(Border.BorderStyle{ .LightRound = {} });
    defer _ = allocator.destroy(border_1);
    _ = panel_main.set_border(border_1.*).title_location(StrAU{ .Center = {} }, TitlePosition{ .Top = {} });
    // PANEL: VOID LEFT OF MAIN
    const panel_main_void_l = Panel.init("VOID L", panel_root, Layout.Vertical, &allocator);
    defer _ = allocator.destroy(panel_main_void_l);
    defer panel_main_void_l.deinit(&allocator);
    // PANEL: VOID RIGHT OF MAIN
    const panel_main_void_r = Panel.init("VOID R", panel_root, Layout.Vertical, &allocator);
    defer _ = allocator.destroy(panel_main_void_r);
    defer panel_main_void_r.deinit(&allocator);
    _ = panel_main_void_l.set_border(border_1.*).title_location(StrAU{ .Left = {} }, TitlePosition{ .Bottom = {} });
    _ = panel_main_void_r.set_border(border_1.*).title_location(StrAU{ .Right = {} }, TitlePosition{ .Bottom = {} });
    _ = panel_root.append_child(panel_main_void_l, null, 1.0);
    _ = panel_root.append_child(panel_main, 30, null);
    _ = panel_root.append_child(panel_main_void_r, null, 1.0);
    var the_app = TheApp.init("Threaded App", panel_root, 20, 15);
    var thread_heartbeat = try std.Thread.spawn(.{}, doAppHeartBeatThread, .{&the_app});
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(.{}, doAppInputThread, .{&the_app});
    defer thread_inputs.join();
    _ = Term.set_color_B(ColorB.init_name(ColorBU{ .Reset = {} }));
}

pub fn doAppInputThread(arg: *TheApp) !void {
    try arg.get_inputs();
}

pub fn doAppHeartBeatThread(arg: *TheApp) !void {
    try arg.get_heart_beat();
}

const TheApp = struct {
    name: []const u8,
    mutex: std.Thread.Mutex = .{},
    is_running: bool,
    heart_beat: bool,
    width: u8,
    height: u8,
    root_panel: *Panel = undefined,

    pub fn init(the_name: []const u8, root_panel: *Panel, width: u8, height: u8) TheApp {
        return .{
            .name = the_name,
            .is_running = true,
            .heart_beat = false,
            .width = width,
            .height = height,
            .root_panel = root_panel,
        };
    }

    pub fn get_inputs(self: *TheApp) !void {
        var reader = ChRead.CharReader.init();
        // var tl_input = TextLine.init(" ");
        // _ = tl_input.abs_xy(0, 8);
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
                    // _ = Term.erase_c_e_s();
                    // _ = tl_input.text_line("Printing...").draw();
                },
                'r' => {
                    // _ = Term.erase_c_e_s();
                    // _ = tl_input.text_line("Running...").draw();
                },
                9 => {
                    // _ = Term.erase_c_e_s();
                    // _ = tl_input.text_line("TAB").draw();
                },
                10 => {
                    // _ = Term.erase_c_e_s();
                    // _ = tl_input.text_line("ENTER").draw();
                },
                32 => {
                    // _ = Term.erase_c_e_s();
                    // _ = tl_input.text_line("SPACE").draw();
                },
                'q' => {
                    _ = Term.erase_c_e_s();
                    self.mutex.lock();
                    defer self.mutex.unlock();
                    self.is_running = false;
                    break;
                },
                33...111 => {
                    //     _ = Term.erase_c_e_s();
                    //     _ = tl_input.text_line(([2]u8{ ch, 0 })[0..]).draw();
                },
                115...126 => {
                    // _ = Term.erase_c_e_s();
                    // _ = tl_input.text_line(([2]u8{ ch, 0 })[0..]).draw();
                },
                27 => {
                    const ch1 = reader.getchar();
                    const cha = if (ch1) |cc| cc else 0;
                    if (cha == '[') {
                        const ch2 = reader.getchar();
                        const chb = if (ch2) |cc| cc else 0;
                        switch (chb) {
                            'A' => {
                                // _ = Term.erase_c_e_s();
                                // _ = tl_input.text_line("Arrow UP").draw();
                            },
                            'B' => {
                                // _ = Term.erase_c_e_s();
                                // _ = tl_input.text_line("Arrow DOWN").draw();
                            },
                            'C' => {
                                // _ = Term.erase_c_e_s();
                                // _ = tl_input.text_line("Arrow RIGHT").draw();
                            },
                            'D' => {
                                // _ = Term.erase_c_e_s();
                                // _ = tl_input.text_line("Arrow LEFT").draw();
                            },
                            else => {},
                        }
                    } else {
                        _ = reader.ungetc_last();
                        // _ = Term.erase_c_e_s();
                        // _ = tl_input.text_line("ESCAPE").draw();
                    }
                },
                else => {},
            }
        }
    }

    pub fn get_heart_beat(self: *TheApp) !void {
        var counter: u8 = 0;
        var tl_heart = TextLine.init("♥");
        _ = tl_heart.fg(ColorF.init_name(ColorFU{ .Blue = {} })); //.abs_xy(0, 5);
        var tl_panelinfo = TextLine.init("q -- quit/exit");
        _ = tl_panelinfo.relative_xy(2, 2);
        const child_head = self.root_panel.child_head.?;
        const child_2 = child_head.sibling_next.?;
        _ = tl_heart.parent_xy(@abs(child_2.anchor_x), @abs(child_2.anchor_y)).relative_xy(2, 1);
        _ = tl_panelinfo.parent_xy(@abs(child_2.anchor_x), @abs(child_2.anchor_y));
        var rt1 = RenderText{ .parent = child_2, .text = &tl_heart, .next_text = null };
        _ = child_2.append_text(&rt1);
        var rt2 = RenderText{ .parent = null, .text = &tl_panelinfo, .next_text = null };
        _ = child_2.append_text(&rt2);
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
                    _ = tl_heart.text_line("♥");
                } else {
                    _ = tl_heart.text_line(" ");
                }
                _ = Term.set_color_F(ColorF.init_name(ColorFU{ .Default = {} }));
            }
            _ = self.root_panel.update();
            _ = tl_heart.parent_xy(@abs(child_2.anchor_x), @abs(child_2.anchor_y));
            _ = tl_panelinfo.parent_xy(@abs(child_2.anchor_x), @abs(child_2.anchor_y));
            _ = self.root_panel.draw();
        }
    }
};
