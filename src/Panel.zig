const std = @import("std");

const TextLine = @import("TextLine.zig").TextLine;
const Border = @import("Border.zig").Border;
const TextAlign = @import("StringStuff.zig").Alignment;
const text_align = @import("StringStuff.zig").stringAlign;
const Term = @import("ansi_terminal.zig");

const TAL = TextAlign{ .Left = {} };
const TAR = TextAlign{ .Right = {} };
const TAC = TextAlign{ .Center = {} };
const TAN = TextAlign{ .None = {} };

/// The direction of layout for children
pub const Layout = enum {
    Horizontal,
    Vertical,
};

/// Vertical alignment for title
pub const PositionTB_E = enum {
    None,
    Top,
    Bottom,
    Center,
};

/// Vertical alignment for title
pub const PositionTB = union(PositionTB_E) {
    None,
    Top,
    Bottom,
    Center,

    pub fn tag(self: PositionTB) u8 {
        return switch (self) {
            .None => 0,
            .Top => 1,
            .Bottom => 2,
            .Center => 3,
        };
    }
};

pub const RenderText = struct {
    parent: ?*Panel = undefined,
    text: *TextLine = undefined,
    next_text: ?*RenderText = null,
    pub fn draw(self: *RenderText) void {
        if (self.parent != null) {
            const p = self.parent.?;
            _ = self.text.parentXY(@as(u32, @abs(p.anchor_x)), @as(u32, @abs(p.anchor_y)));
        }
        _ = self.text.draw();
        if (self.next_text != null) {
            _ = self.next_text.?.draw();
        }
    }
};

/// The main (full) screen and sub-sections of it
pub const Panel = struct {
    title: ?[]const u8 = undefined,
    title_align: TextAlign = undefined,
    title_position: PositionTB = undefined,
    anchor_x: i32 = undefined,
    anchor_y: i32 = undefined,
    parent_width: *i32 = undefined,
    parent_height: *i32 = undefined,
    width: i32 = undefined,
    height: i32 = undefined,
    minimum_width: i32 = undefined,
    minimum_height: i32 = undefined,
    layout: Layout = undefined,
    parent: ?*Panel = undefined,
    child_head: ?*Panel = undefined,
    sibling_next: ?*Panel = undefined,
    render_text_next: ?*RenderText = undefined,
    size_absolute: ?i32 = undefined,
    size_relative: ?f32 = undefined,
    border: ?Border = undefined,
    allocator: *std.mem.Allocator = undefined,
    ch_sizes_absolute: std.ArrayList(i32) = undefined,
    ch_sizes_relative: std.ArrayList(f32) = undefined,

    /// Initialize a sub-panel
    pub fn init(title: ?[]const u8, parent: *Panel, layout: Layout, allocator: *std.mem.Allocator) *Panel {
        const panel = allocator.create(Panel) catch unreachable;
        panel.* = Panel{
            .title = title,
            .title_position = PositionTB{ .None = {} },
            .title_align = TAN,
            .anchor_x = 1,
            .anchor_y = 1,
            .parent = parent,
            .layout = layout,
            .allocator = allocator,
            .parent_width = &parent.width,
            .parent_height = &parent.height,
            .minimum_width = @as(i32, 12),
            .minimum_height = @as(i32, 4),
            .width = @as(i32, 0),
            .height = @as(i32, 0),
            .render_text_next = null,
            .child_head = null,
            .sibling_next = null,
            .size_absolute = null,
            .size_relative = null,
            .border = null,
            .ch_sizes_absolute = std.ArrayList(i32).init(allocator.*),
            .ch_sizes_relative = std.ArrayList(f32).init(allocator.*),
        };
        return panel;
    }

    /// Initialize the root panel, i.e., the whole screen
    pub fn initRoot(title: ?[]const u8, parent_w: *i32, parent_h: *i32, layout: Layout, allocator: *std.mem.Allocator) *Panel {
        const panel = allocator.create(Panel) catch unreachable;
        panel.* = Panel{
            .title = title,
            .title_position = PositionTB{ .None = {} },
            .title_align = TAN,
            .parent = null,
            .anchor_x = 1,
            .anchor_y = 1,
            .layout = layout,
            .allocator = allocator,
            .parent_width = parent_w,
            .parent_height = parent_h,
            .minimum_width = @as(i32, 12),
            .minimum_height = @as(i32, 4),
            .width = @as(i32, 0),
            .height = @as(i32, 0),
            .child_head = null,
            .sibling_next = null,
            .render_text_next = null,
            .size_absolute = null,
            .size_relative = null,
            .border = null,
            .ch_sizes_absolute = std.ArrayList(i32).init(allocator.*),
            .ch_sizes_relative = std.ArrayList(f32).init(allocator.*),
        };
        panel.width = parent_w.*;
        panel.height = parent_h.*;
        return panel;
    }

    /// Clean up memory
    pub fn deinit(self: *Panel, allocator: *std.mem.Allocator) void {
        _ = allocator.destroy(&self.ch_sizes_absolute);
        _ = allocator.destroy(&self.ch_sizes_relative);
    }

    /// Add a new child to the end of children's list
    pub fn appendChild(self: *Panel, child: *Panel, absolute_size: ?i32, relative_size: ?f32) *Panel {
        var the_child = child;
        the_child.size_absolute = absolute_size;
        the_child.size_relative = relative_size;
        const s_abs = absolute_size orelse 0;
        const s_rel = relative_size orelse 0.0;
        the_child.parent = self;
        if (self.child_head == null) {
            self.child_head = the_child;
        } else {
            const current_child = self.child_head.?;
            var last_child = self.getLastChild(current_child).?;
            last_child.sibling_next = the_child;
        }
        _ = self.ch_sizes_absolute.append(s_abs) catch unreachable;
        _ = self.ch_sizes_relative.append(s_rel) catch unreachable;
        _ = self.update();
        return self;
    }

    /// Find the last child of the current panel
    pub fn getLastChild(self: *Panel, child: ?*Panel) ?*Panel {
        if (child == null) {
            return null;
        } else {
            const theChild = child.?;
            if (theChild.sibling_next == null) {
                return theChild;
            } else {
                return self.getLastChild(theChild.sibling_next);
            }
        }
    }

    /// Add a new child to the end of children's list
    pub fn appendText(self: *Panel, child: *RenderText) *Panel {
        var the_child = child;
        the_child.parent = self;
        if (self.render_text_next == null) {
            self.render_text_next = the_child;
        } else {
            const current_child = self.render_text_next.?;
            var last_child = self.getLastText(current_child).?;
            last_child.next_text = the_child;
        }
        // _ = self.draw();
        return self;
    }

    /// Find the last child of the current panel
    pub fn getLastText(self: *Panel, child: ?*RenderText) ?*RenderText {
        if (child == null) {
            return null;
        } else {
            const theChild = child.?;
            if (theChild.next_text == null) {
                return theChild;
            } else {
                return self.getLastText(theChild.next_text);
            }
        }
    }

    /// Set title's location (h: left, center, right; v: top, center, bottom)
    pub fn titleLocation(self: *Panel, horizontal: ?TextAlign, vertical: ?PositionTB) *Panel {
        if (horizontal != null) {
            const a = horizontal.?;
            self.title_align = a;
        }
        if (vertical != null) {
            const p = vertical.?;
            self.title_position = p;
        }
        return self;
    }

    /// Set minimum width when panel is rendered
    pub fn setMinWidth(self: *Panel, width: i32) *Panel {
        self.minimum_width = width;
        return self;
    }

    /// Set minimum height when panel is rendered
    pub fn setMinHeight(self: *Panel, height: i32) *Panel {
        self.minimum_height = height;
        return self;
    }

    /// Update panel sizes according to current screen size
    /// and the size of parent panels with layout and border directives
    pub fn update(self: *Panel) *Panel {
        if (self.parent == null) {
            self.width = self.parent_width.*;
            self.height = self.parent_height.*;
            self.anchor_x = 1;
            self.anchor_y = 1;
        } else {
            const p = self.parent.?;
            const the_border = p.border orelse null;
            const the_layout = p.layout;
            if (the_layout == Layout.Vertical) {
                if (the_border != null) {
                    const w_l = the_border.?.left != null;
                    const w_r = the_border.?.right != null;
                    self.width = p.width;
                    if (w_l == true) {
                        self.width -= 1;
                    }
                    if (w_r == true) {
                        self.width -= 1;
                    }
                } else {
                    self.width = p.width;
                }
                if (self.size_absolute != null) {
                    self.height = self.size_absolute.?;
                } else if (self.size_relative != null) {
                    var sum_a: i32 = 0;
                    for (p.ch_sizes_absolute.items) |item| {
                        sum_a += item;
                    }
                    var sum_r: f32 = 0;
                    for (p.ch_sizes_relative.items) |item| {
                        sum_r += item;
                    }
                    var p_h = p.height;
                    if (the_border != null) {
                        const h_t = the_border.?.top != null;
                        const h_b = the_border.?.bottom != null;
                        if (h_t == true) {
                            p_h -= 1;
                        }
                        if (h_b == true) {
                            p_h -= 1;
                        }
                    }
                    p_h -= sum_a;
                    const h: i32 = @as(i32, @intFromFloat(@as(f32, @floatFromInt(p_h)) * self.size_relative.? / sum_r));
                    self.height = h;
                }
            } else {
                if (the_border != null) {
                    self.height = p.height; // - 2;
                    const h_t = the_border.?.top != null;
                    const h_b = the_border.?.bottom != null;
                    if (h_t == true) {
                        self.height -= 1;
                    }
                    if (h_b == true) {
                        self.height -= 1;
                    }
                } else {
                    self.height = p.height;
                }
                if (self.size_absolute != null) {
                    self.width = self.size_absolute.?;
                } else if (self.size_relative != null) {
                    var sum_a: i32 = 0;
                    for (p.ch_sizes_absolute.items) |item| {
                        sum_a += item;
                    }
                    var sum_r: f32 = 0;
                    for (p.ch_sizes_relative.items) |item| {
                        sum_r += item;
                    }
                    var p_w = p.width;
                    if (the_border != null) {
                        const w_l = the_border.?.left != null;
                        const w_r = the_border.?.right != null;
                        self.width = p.width;
                        if (w_l == true) {
                            p_w -= 1;
                        }
                        if (w_r == true) {
                            p_w -= 1;
                        }
                    }
                    p_w -= sum_a;
                    const w: i32 = @as(i32, @intFromFloat(@as(f32, @floatFromInt(p_w)) * self.size_relative.? / sum_r));
                    self.width = w;
                }
                // else {
                //         self.width = self.parent.?.width;
                //     }
            }
            // }
            if (self.sibling_next != null) {
                var bx: i32 = 0;
                var by: i32 = 0;
                if (p.border != null) {
                    bx += 1;
                    by += 1;
                }
                const w = if (p.layout == Layout.Vertical) 0 else self.width; // + bx;
                const h = if (p.layout == Layout.Vertical) self.height else 0; // + by else 0;
                self.sibling_next.?.anchor_x = self.anchor_x + w;
                self.sibling_next.?.anchor_y = self.anchor_y + h;
                // }
                _ = self.sibling_next.?.update();
            }
        }
        if (self.child_head != null) {
            var bx: i32 = 0;
            var by: i32 = 0;
            if (self.border != null) {
                bx += 1;
                by += 1;
            }
            self.child_head.?.anchor_x = self.anchor_x + bx;
            self.child_head.?.anchor_y = self.anchor_y + by;
            _ = self.child_head.?.update();
        }
        return self;
    }

    /// Configure the border settings
    pub fn setBorder(self: *Panel, border: ?Border) *Panel {
        self.border = border;
        return self;
    }

    /// Draw the panes
    pub fn draw(self: *Panel) *Panel {
        _ = self.update();
        if (self.parent == null) {
            _ = Term.clearScreen();
        }
        if ((self.width >= self.minimum_width) and (self.height >= self.minimum_height)) {
            const hh = @as(usize, @abs(self.height)); // + 1;
            for (0..hh) |row| {
                var tl_buffer_1: [512]u8 = undefined;
                var tl_buffer_2: [512]u8 = undefined;
                var tl_buffer_3: [512]u8 = undefined;
                var tl = TextLine.init("");
                _ = tl.absXY(@abs(self.anchor_x), @abs(self.anchor_y) + @as(u32, @intCast(row)));
                if (self.border != null) {
                    const border = self.border.?;
                    const b_t = border.top orelse ' ';
                    const b_b = border.bottom orelse ' ';
                    const b_l = border.left orelse ' ';
                    const b_r = border.right orelse ' ';
                    const b_tl = border.top_left orelse ' ';
                    const b_tr = border.top_right orelse ' ';
                    const b_bl = border.bottom_left orelse ' ';
                    const b_br = border.bottom_right orelse ' ';
                    if (row == 0) {
                        if ((self.title != null) and (self.title_position.tag() == 1)) {
                            const ts = text_align(&tl_buffer_1, self.title.?, ' ', self.title.?.len + 2, TAC);
                            const ts1 = text_align(&tl_buffer_2, ts, b_t, ts.len + 2, TAC);
                            const ts2 = text_align(&tl_buffer_3, ts1, b_t, @as(usize, @abs(self.width)) - 2, self.title_align);
                            const ts3 = text_align(&tl_buffer_1, ts2, b_tl, @as(usize, @abs(self.width)) - 1, TAR);
                            const ts4 = text_align(&tl_buffer_2, ts3, b_tr, @as(usize, @abs(self.width)), TAL);
                            _ = tl.textLine(ts4).draw();
                        } else {
                            const ts2 = text_align(&tl_buffer_3, "", b_t, @as(usize, @abs(self.width)) - 2, self.title_align);
                            const ts3 = text_align(&tl_buffer_1, ts2, b_tl, @as(usize, @abs(self.width)) - 1, TAR);
                            const ts4 = text_align(&tl_buffer_2, ts3, b_tr, @as(usize, @abs(self.width)), TAL);
                            _ = tl.textLine(ts4).draw();
                        }
                    } else if (row == self.height - 1) {
                        if ((self.title != null) and (self.title_position.tag() == 2)) {
                            const ts = text_align(&tl_buffer_1, self.title.?, ' ', self.title.?.len + 2, TAC);
                            const ts1 = text_align(&tl_buffer_2, ts, b_b, ts.len + 2, TAC);
                            const ts2 = text_align(&tl_buffer_3, ts1, b_b, @as(usize, @abs(self.width)) - 2, self.title_align);
                            const ts3 = text_align(&tl_buffer_1, ts2, b_bl, @as(usize, @abs(self.width)) - 1, TAR);
                            const ts4 = text_align(&tl_buffer_2, ts3, b_br, @as(usize, @abs(self.width)), TAL);
                            _ = tl.textLine(ts4).draw();
                        } else {
                            const ts2 = text_align(&tl_buffer_3, "", b_b, @as(usize, @abs(self.width)) - 2, self.title_align);
                            const ts3 = text_align(&tl_buffer_1, ts2, b_bl, @as(usize, @abs(self.width)) - 1, TAR);
                            const ts4 = text_align(&tl_buffer_2, ts3, b_br, @as(usize, @abs(self.width)), TAL);
                            _ = tl.textLine(ts4).draw();
                        }
                    } else {
                        const ts2 = text_align(&tl_buffer_3, "", ' ', @as(usize, @abs(self.width)) - 2, self.title_align);
                        const ts3 = text_align(&tl_buffer_1, ts2, b_l, @as(usize, @abs(self.width)) - 1, TAR);
                        const ts4 = text_align(&tl_buffer_2, ts3, b_r, @as(usize, @abs(self.width)), TAL);
                        _ = tl.textLine(ts4).draw();
                    }
                } else {
                    if (self.parent != null) {
                        const t_line = text_align(&tl_buffer_1, "", ' ', @as(usize, @abs(self.width)) - 2, TextAlign{ .Left = {} });
                        _ = tl.textLine(t_line).draw();
                    }
                }
            }
            if (self.render_text_next != null) {
                const r_text = self.render_text_next.?;
                _ = r_text.draw();
            }
        }
        // Draw other siblings
        if (self.sibling_next != null) {
            _ = self.sibling_next.?.draw();
        }
        // Draw the "children"
        if (self.child_head != null) {
            _ = self.child_head.?.draw();
        }
        return self;
    }
};
