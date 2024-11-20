const std = @import("std");

const TextLine = @import(
    "TextLine.zig",
).TextLine;
const Border = @import(
    "Border.zig",
).Border;
const TextAlign = @import(
    "StringStuff.zig",
).Alignment;
const stringAlign = @import(
    "StringStuff.zig",
).stringAlign;
const stringLen = @import(
    "StringStuff.zig",
).stringLen;
const Term = @import(
    "ansi_terminal.zig",
);
const Location = @import(
    "Location.zig",
).Location;
const Face = @import(
    "Location.zig",
).Face;
const FaceE = @import(
    "Location.zig",
).FaceE;
const BufWriter = @import(
    "SimpleBufferedWriter.zig",
).SimpleBufferedWriter;

const TAL = TextAlign.Left;
const TAR = TextAlign.Right;
const TAC = TextAlign.Center;
const TAN = TextAlign.None;

/// The direction of layout for children
pub const Layout = enum {
    Horizontal,
    Vertical,
};

/// Vertical alignment for title
pub const PositionTB = enum {
    None,
    Top,
    Bottom,
    Center,

    const Self = @This();

    /// Get the numeric value of the position
    pub fn tag(self: Self) u8 {
        return switch (self) {
            .None => 0,
            .Top => 1,
            .Bottom => 2,
            .Center => 3,
        };
    }
};

/// Text element relative to the panel
pub const RenderText = struct {
    parent: ?*Panel = undefined,
    text: *TextLine = undefined,
    next_text: ?*RenderText = null,

    const Self = @This();

    /// Draw RenderText items
    pub fn draw(self: *Self) void {
        if (self.parent) |p| {
            if (p.writer.list.len > 3072) {
                _ = p.writer.flush() catch unreachable;
            }
            _ = self.text.parentXY(
                @as(u32, @abs(p.anchor_x)),
                @as(u32, @abs(p.anchor_y)),
            );
        }
        _ = self.text.draw();
        if (self.next_text) |n| {
            _ = n.draw();
        }
    }
};

/// Element that repeats a "text" at an array of coordinates
pub const RenderTextArray = struct {
    parent: ?*Panel = undefined,
    delta_x: i32 = 0,
    delta_y: i32 = 0,
    multi_x: i32 = 1, // size of the text, 1 => one char
    multi_y: i32 = 1,
    /// Text to draw repeatedly
    text: *TextLine = undefined,
    /// If set, this would be the first text of the array
    text_first: ?*TextLine = null,
    /// Currently not used
    text_alt: ?*TextLine = null,
    /// Coordinates of the texts
    coordinates: *std.ArrayList(Location) = undefined,
    /// Next array of texts
    next_array: ?*RenderTextArray = null,

    const Self = @This();

    fn drawItem(
        self: *Self,
        parent: *Panel,
        item: Location,
        index: usize,
    ) void {
        const nx: i32 = item.x * self.multi_x + self.delta_x;
        const ny: i32 = item.y * self.multi_y + self.delta_y;
        if (parent.writer.list.len > 3072) {
            _ = parent.writer.flush() catch unreachable;
        }
        if (index == 0) {
            if (self.text_first) |text_first| {
                _ = text_first.parentXY(
                    @as(u32, @abs(parent.anchor_x)),
                    @as(u32, @abs(parent.anchor_y)),
                );
                _ = text_first.relativeXY(
                    nx,
                    ny,
                );
                _ = text_first.draw();
            } else {
                _ = self.text.parentXY(
                    @as(u32, @abs(parent.anchor_x)),
                    @as(u32, @abs(parent.anchor_y)),
                );
                _ = self.text.relativeXY(
                    nx,
                    ny,
                );
                _ = self.text.draw();
            }
        } else {
            _ = self.text.parentXY(
                @as(u32, @abs(parent.anchor_x)),
                @as(u32, @abs(parent.anchor_y)),
            );
            _ = self.text.relativeXY(
                nx,
                ny,
            );
            _ = self.text.draw();
        }
    }

    /// Draw RenderTextArray items
    pub fn draw(self: *Self) void {
        if (self.parent) |p| {
            if (p.writer.list.len > 3072) {
                _ = p.writer.flush() catch unreachable;
            }
            _ = self.text.parentXY(
                @as(u32, @abs(p.anchor_x)),
                @as(u32, @abs(p.anchor_y)),
            );
            // }
            for (self.coordinates.items, 0..) |item, index| {
                self.drawItem(p, item, index);
            }
            _ = p.writer.flush() catch unreachable;
        }
        if (self.next_array) |n| {
            _ = n.draw();
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
    full_width: *i32 = undefined,
    full_height: *i32 = undefined,
    width: i32 = undefined,
    height: i32 = undefined,
    minimum_width: i32 = undefined,
    minimum_height: i32 = undefined,
    layout: Layout = undefined,
    parent: ?*Panel = undefined,
    child_head: ?*Panel = undefined,
    sibling_next: ?*Panel = undefined,
    render_text_next: ?*RenderText = undefined,
    render_array_next: ?*RenderTextArray = undefined,
    size_absolute: ?i32 = undefined,
    size_relative: ?f32 = undefined,
    border: ?Border = undefined,
    allocator: *std.mem.Allocator = undefined,
    writer: *BufWriter = undefined,
    ch_sizes_absolute: std.ArrayList(
        i32,
    ) = undefined,
    ch_sizes_relative: std.ArrayList(
        f32,
    ) = undefined,

    const Self = @This();

    /// Initialize a sub-panel
    pub fn init(
        title: ?[]const u8,
        parent: *Self,
        layout: Layout,
        allocator: *std.mem.Allocator,
    ) *Self {
        const panel = allocator.create(
            Self,
        ) catch unreachable;
        panel.* = Self{
            .title = title,
            .title_position = PositionTB.None,
            .title_align = TAN,
            .anchor_x = 1,
            .anchor_y = 1,
            .parent = parent,
            .layout = layout,
            .allocator = allocator,
            .writer = parent.writer,
            .parent_width = &parent.width,
            .parent_height = &parent.height,
            .full_width = &parent.width,
            .full_height = &parent.height,
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
            .ch_sizes_absolute = std.ArrayList(
                i32,
            ).init(allocator.*),
            .ch_sizes_relative = std.ArrayList(
                f32,
            ).init(allocator.*),
        };
        return panel;
    }

    /// Initialize the root panel, i.e., the whole screen
    pub fn initRoot(
        title: ?[]const u8,
        parent_w: *i32,
        parent_h: *i32,
        layout: Layout,
        allocator: *std.mem.Allocator,
        writer: *BufWriter,
    ) *Self {
        const panel = allocator.create(
            Self,
        ) catch unreachable;
        panel.* = Self{
            .title = title,
            .title_position = PositionTB.None,
            .title_align = TAN,
            .parent = null,
            .anchor_x = 1,
            .anchor_y = 1,
            .layout = layout,
            .allocator = allocator,
            .writer = writer,
            .parent_width = parent_w,
            .parent_height = parent_h,
            .full_width = parent_w,
            .full_height = parent_h,
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
            .ch_sizes_absolute = std.ArrayList(
                i32,
            ).init(allocator.*),
            .ch_sizes_relative = std.ArrayList(
                f32,
            ).init(allocator.*),
        };
        panel.width = parent_w.*;
        panel.height = parent_h.*;
        return panel;
    }

    /// Clean up memory
    pub fn deinit(
        self: *Self,
        allocator: *std.mem.Allocator,
    ) void {
        _ = allocator.destroy(&self.ch_sizes_absolute);
        _ = allocator.destroy(&self.ch_sizes_relative);
    }

    /// Add a new child to the end of children's list
    pub fn appendChild(
        self: *Self,
        child: *Self,
        absolute_size: ?i32,
        relative_size: ?f32,
    ) *Self {
        var the_child = child;
        the_child.full_width = self.full_width;
        the_child.full_height = self.full_height;
        the_child.size_absolute = absolute_size;
        the_child.size_relative = relative_size;
        const s_abs = absolute_size orelse 0;
        const s_rel = relative_size orelse 0.0;
        the_child.parent = self;
        if (self.child_head) |current_child| {
            if (self.getLastChild(
                current_child,
            )) |last_child| {
                last_child.sibling_next = the_child;
            }
        } else {
            self.child_head = the_child;
        }
        _ = self.ch_sizes_absolute.append(
            s_abs,
        ) catch unreachable;
        _ = self.ch_sizes_relative.append(
            s_rel,
        ) catch unreachable;
        _ = self.update();
        return self;
    }

    /// Find the last child of the current panel
    pub fn getLastChild(
        self: *Self,
        child: ?*Self,
    ) ?*Self {
        if (child) |the_child| {
            if (the_child.sibling_next) |n| {
                return self.getLastChild(n);
            } else {
                return the_child;
            }
        } else {
            return null;
        }
    }

    /// Add a new child to the end of children's list
    pub fn appendText(
        self: *Self,
        child: *RenderText,
    ) *Self {
        var the_child = child;
        the_child.parent = self;
        if (self.render_text_next) |current_child| {
            if (self.getLastText(current_child)) |last_child| {
                last_child.next_text = the_child;
            }
        } else {
            self.render_text_next = the_child;
        }
        return self;
    }

    /// Find the last child of the current panel
    pub fn getLastText(
        self: *Self,
        child: ?*RenderText,
    ) ?*RenderText {
        if (child) |the_child| {
            if (the_child.next_text) |n| {
                return self.getLastText(n);
            } else {
                return the_child;
            }
        } else {
            return null;
        }
    }

    /// Add a new child to the end of children's list
    pub fn appendArray(
        self: *Self,
        child: *RenderTextArray,
    ) *Self {
        var the_child = child;
        the_child.parent = self;
        if (self.render_array_next) |current_child| {
            if (self.getLastArray(current_child)) |last_child| {
                last_child.next_array = the_child;
            }
        } else {
            self.render_array_next = the_child;
        }
        return self;
    }

    /// Find the last child of the current panel
    pub fn getLastArray(
        self: *Self,
        child: ?*RenderTextArray,
    ) ?*RenderTextArray {
        if (child) |the_child| {
            if (the_child.next_array) |n| {
                return self.getLastArray(n);
            } else {
                return the_child;
            }
        } else {
            return null;
        }
    }

    /// Set title's location (h: left, center, right; v: top, center, bottom)
    pub fn titleLocation(
        self: *Self,
        horizontal: ?TextAlign,
        vertical: ?PositionTB,
    ) *Self {
        if (horizontal) |h| {
            self.title_align = h;
        }
        if (vertical) |v| {
            self.title_position = v;
        }
        return self;
    }

    /// Set minimum width when panel is rendered
    pub fn setMinWidth(
        self: *Self,
        width: i32,
    ) *Self {
        self.minimum_width = width;
        return self;
    }

    /// Set minimum height when panel is rendered
    pub fn setMinHeight(
        self: *Self,
        height: i32,
    ) *Self {
        self.minimum_height = height;
        return self;
    }

    /// Update panel sizes according to current screen size
    /// and the size of parent panels with layout and border directives
    pub fn update(self: *Self) *Self {
        if (self.parent) |p| {
            const the_border = p.border orelse null;
            const the_layout = p.layout;
            if (the_layout == Layout.Vertical) {
                if (the_border) |tb| {
                    const w_l = tb.left != null;
                    const w_r = tb.right != null;
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
                if (self.size_absolute) |sa| {
                    // TODO:
                    if ((self.anchor_y + sa) <= self.full_height.*) {
                        self.height = sa;
                    } else {
                        self.height = 0;
                    }
                } else if (self.size_relative) |sr| {
                    var sum_a: i32 = 0;
                    for (p.ch_sizes_absolute.items) |item| {
                        sum_a += item;
                    }
                    var sum_r: f32 = 0;
                    for (p.ch_sizes_relative.items) |item| {
                        sum_r += item;
                    }
                    var p_h = p.height;
                    if (the_border) |tb| {
                        const h_t = tb.top != null;
                        const h_b = tb.bottom != null;
                        if (h_t == true) {
                            p_h -= 1;
                        }
                        if (h_b == true) {
                            p_h -= 1;
                        }
                    }
                    p_h -= sum_a;
                    const h: i32 = @as(
                        i32,
                        @intFromFloat(@as(
                            f32,
                            @floatFromInt(p_h),
                        ) * sr / sum_r),
                    );
                    self.height = h;
                }
            } else {
                if (the_border) |tb| {
                    self.height = p.height; // - 2;
                    const h_t = tb.top != null;
                    const h_b = tb.bottom != null;
                    if (h_t == true) {
                        self.height -= 1;
                    }
                    if (h_b == true) {
                        self.height -= 1;
                    }
                } else {
                    self.height = p.height;
                }
                if (self.size_absolute) |sa| {
                    // TODO:
                    if ((self.anchor_x + sa) <= self.full_width.*) {
                        self.width = sa;
                    } else {
                        self.width = 0;
                    }
                } else if (self.size_relative) |sr| {
                    var sum_a: i32 = 0;
                    for (p.ch_sizes_absolute.items) |item| {
                        sum_a += item;
                    }
                    var sum_r: f32 = 0;
                    for (p.ch_sizes_relative.items) |item| {
                        sum_r += item;
                    }
                    var p_w = p.width;
                    if (the_border) |tb| {
                        const w_l = tb.left != null;
                        const w_r = tb.right != null;
                        self.width = p.width;
                        if (w_l == true) {
                            p_w -= 1;
                        }
                        if (w_r == true) {
                            p_w -= 1;
                        }
                    }
                    p_w -= sum_a;
                    const w: i32 = @as(
                        i32,
                        @intFromFloat(@as(
                            f32,
                            @floatFromInt(p_w),
                        ) * sr / sum_r),
                    );
                    self.width = w;
                }
            }
            if (self.sibling_next) |n| {
                var bx: i32 = 0;
                var by: i32 = 0;
                if (p.border) |_| {
                    bx += 1;
                    by += 1;
                }
                const w = if (p.layout == Layout.Vertical) 0 //
                else self.width; // + bx;
                const h = if (p.layout == Layout.Vertical) self.height //
                else 0; // + by else 0;
                n.anchor_x = self.anchor_x + w;
                n.anchor_y = self.anchor_y + h;
                // }
                _ = n.update();
            }
        } else {
            self.width = self.parent_width.*;
            self.height = self.parent_height.*;
            self.anchor_x = 1;
            self.anchor_y = 1;
        }
        if (self.child_head) |current_child| {
            var bx: i32 = 0;
            var by: i32 = 0;
            if (self.border) |_| {
                bx += 1;
                by += 1;
            }
            current_child.anchor_x = self.anchor_x + bx;
            current_child.anchor_y = self.anchor_y + by;
            _ = current_child.update();
        }
        return self;
    }

    /// Configure the border settings
    pub fn setBorder(
        self: *Self,
        border: ?Border,
    ) *Self {
        self.border = border;
        return self;
    }

    fn drawFrame(self: *Self) void {
        var b_t: u21 = @as(u21, ' ');
        var b_b: u21 = @as(u21, ' ');
        var b_l: u21 = @as(u21, ' ');
        var b_r: u21 = @as(u21, ' ');
        var b_tl: u21 = @as(u21, ' ');
        var b_tr: u21 = @as(u21, ' ');
        var b_bl: u21 = @as(u21, ' ');
        var b_br: u21 = @as(u21, ' ');
        var tl = TextLine.init(
            self.writer,
            "",
        );
        if (self.border) |f| {
            _ = tl.setColor(f.color);
            b_t = f.top orelse ' ';
            b_b = f.bottom orelse ' ';
            b_l = f.left orelse ' ';
            b_r = f.right orelse ' ';
            b_tl = f.top_left orelse ' ';
            b_tr = f.top_right orelse ' ';
            b_bl = f.bottom_left orelse ' ';
            b_br = f.bottom_right orelse ' ';
        }
        var tl_buffer_1: [512]u8 = undefined;
        var tl_buffer_2: [512]u8 = undefined;
        var tl_buffer_3: [512]u8 = undefined;
        const hh = @as(usize, @abs(self.height)); // + 1;
        for (0..hh) |row| {
            if (self.writer.list.len > 3072) {
                _ = self.writer.flush() catch unreachable;
            }
            _ = tl.absXY(
                @abs(self.anchor_x),
                @abs(self.anchor_y) + @as(u32, @intCast(row)),
            );
            if (row == 0) {
                const ts2 = stringAlign(
                    &tl_buffer_1,
                    "",
                    b_t,
                    @as(usize, @abs(self.width)) - 2,
                    self.title_align,
                );
                const ts3 = stringAlign(
                    &tl_buffer_2,
                    ts2,
                    b_tl,
                    @as(usize, @abs(self.width)) - 1,
                    TAR,
                );
                const ts4 = stringAlign(
                    &tl_buffer_3,
                    ts3,
                    b_tr,
                    @as(usize, @abs(self.width)),
                    TAL,
                );
                _ = tl.textLine(ts4).draw();
            } else if (row == self.height - 1) {
                const ts2 = stringAlign(
                    &tl_buffer_1,
                    "",
                    b_b,
                    @as(usize, @abs(self.width)) - 2,
                    self.title_align,
                );
                const ts3 = stringAlign(
                    &tl_buffer_2,
                    ts2,
                    b_bl,
                    @as(usize, @abs(self.width)) - 1,
                    TAR,
                );
                const ts4 = stringAlign(
                    &tl_buffer_3,
                    ts3,
                    b_br,
                    @as(usize, @abs(self.width)),
                    TAL,
                );
                _ = tl.textLine(ts4).draw();
            } else {
                const ts2 = stringAlign(
                    &tl_buffer_1,
                    "",
                    ' ',
                    @as(usize, @abs(self.width)) - 2,
                    self.title_align,
                );
                const ts3 = stringAlign(
                    &tl_buffer_2,
                    ts2,
                    b_l,
                    @as(usize, @abs(self.width)) - 1,
                    TAR,
                );
                const ts4 = stringAlign(
                    &tl_buffer_3,
                    ts3,
                    b_r,
                    @as(usize, @abs(self.width)),
                    TAL,
                );
                _ = tl.textLine(ts4).draw();
            }
        }
        if (self.title) |title| {
            const title_len = stringLen(title);
            if (title_len < self.width - 4) {
                _ = @memset(&tl_buffer_1, 0);
                const ts2 = stringAlign(
                    &tl_buffer_1,
                    title,
                    ' ',
                    title_len + 2,
                    TAC,
                );
                var coord_y: i32 = @as(i32, 0);
                var coord_x: i32 = @as(i32, 2);
                if (self.title_position.tag() == 2) {
                    coord_y = @intCast(hh - 1);
                }
                if (self.title_align.tag() == 2) {
                    coord_x = @intCast(self.width - 4);
                    coord_x -= @intCast(title_len);
                } else if (self.title_align.tag() == 3) {
                    const t_len: i32 = @intCast(title_len);
                    coord_x = @divFloor(self.width - t_len, @as(i32, 2)) - 1;
                }
                _ = tl.absXY(
                    @abs(self.anchor_x + coord_x),
                    @abs(self.anchor_y) + @as(u32, @intCast(coord_y)),
                );
                _ = tl.textLine(ts2).draw();
            }
        }
    }

    fn drawRow(self: *Self, row: usize) void {
        if (self.writer.list.len > 3072) {
            _ = self.writer.flush() catch unreachable;
        }
        var tl_buffer_1: [512]u8 = undefined;
        var tl_buffer_2: [512]u8 = undefined;
        var tl_buffer_3: [512]u8 = undefined;
        var tl = TextLine.init(
            self.writer,
            "",
        );
        _ = tl.absXY(
            @abs(self.anchor_x),
            @abs(self.anchor_y) + @as(u32, @intCast(row)),
        );
        if (self.border) |border| {
            _ = tl.setColor(border.color);
            const b_t = border.top orelse ' ';
            const b_b = border.bottom orelse ' ';
            const b_l = border.left orelse ' ';
            const b_r = border.right orelse ' ';
            const b_tl = border.top_left orelse ' ';
            const b_tr = border.top_right orelse ' ';
            const b_bl = border.bottom_left orelse ' ';
            const b_br = border.bottom_right orelse ' ';
            if (row == 0) {
                if ((self.title != null) and //
                    (self.title_position.tag() == 1))
                {
                    const title_len = stringLen(self.title.?);
                    const ts = stringAlign(
                        &tl_buffer_1,
                        self.title.?,
                        ' ',
                        title_len + 2,
                        TAC,
                    );
                    const ts1 = stringAlign(
                        &tl_buffer_2,
                        ts,
                        b_t,
                        title_len + 4,
                        TAC,
                    );
                    const ts2 = stringAlign(
                        &tl_buffer_3,
                        ts1,
                        b_t,
                        @as(usize, @abs(self.width)) - 2,
                        self.title_align,
                    );
                    const ts3 = stringAlign(
                        &tl_buffer_1,
                        ts2,
                        b_tl,
                        @as(usize, @abs(self.width)) - 1,
                        TAR,
                    );
                    const ts4 = stringAlign(
                        &tl_buffer_2,
                        ts3,
                        b_tr,
                        @as(usize, @abs(self.width)),
                        TAL,
                    );
                    _ = tl.textLine(ts4).draw();
                } else {
                    const ts2 = stringAlign(
                        &tl_buffer_3,
                        "",
                        b_t,
                        @as(usize, @abs(self.width)) - 2,
                        self.title_align,
                    );
                    const ts3 = stringAlign(
                        &tl_buffer_1,
                        ts2,
                        b_tl,
                        @as(usize, @abs(self.width)) - 1,
                        TAR,
                    );
                    const ts4 = stringAlign(
                        &tl_buffer_2,
                        ts3,
                        b_tr,
                        @as(usize, @abs(self.width)),
                        TAL,
                    );
                    _ = tl.textLine(ts4).draw();
                }
            } else if (row == self.height - 1) {
                if ((self.title != null) and //
                    (self.title_position.tag() == 2))
                {
                    const title_len = stringLen(self.title.?);
                    const ts = stringAlign(
                        &tl_buffer_1,
                        self.title.?,
                        ' ',
                        title_len + 2,
                        TAC,
                    );
                    const ts1 = stringAlign(
                        &tl_buffer_2,
                        ts,
                        b_b,
                        title_len + 4,
                        TAC,
                    );
                    const ts2 = stringAlign(
                        &tl_buffer_3,
                        ts1,
                        b_b,
                        @as(usize, @abs(self.width)) - 2,
                        self.title_align,
                    );
                    const ts3 = stringAlign(
                        &tl_buffer_1,
                        ts2,
                        b_bl,
                        @as(usize, @abs(self.width)) - 1,
                        TAR,
                    );
                    const ts4 = stringAlign(
                        &tl_buffer_2,
                        ts3,
                        b_br,
                        @as(usize, @abs(self.width)),
                        TAL,
                    );
                    _ = tl.textLine(ts4).draw();
                } else {
                    const ts2 = stringAlign(
                        &tl_buffer_3,
                        "",
                        b_b,
                        @as(usize, @abs(self.width)) - 2,
                        self.title_align,
                    );
                    const ts3 = stringAlign(
                        &tl_buffer_1,
                        ts2,
                        b_bl,
                        @as(usize, @abs(self.width)) - 1,
                        TAR,
                    );
                    const ts4 = stringAlign(
                        &tl_buffer_2,
                        ts3,
                        b_br,
                        @as(usize, @abs(self.width)),
                        TAL,
                    );
                    _ = tl.textLine(ts4).draw();
                }
            } else {
                const ts2 = stringAlign(
                    &tl_buffer_3,
                    "",
                    ' ',
                    @as(usize, @abs(self.width)) - 2,
                    self.title_align,
                );
                const ts3 = stringAlign(
                    &tl_buffer_1,
                    ts2,
                    b_l,
                    @as(usize, @abs(self.width)) - 1,
                    TAR,
                );
                const ts4 = stringAlign(
                    &tl_buffer_2,
                    ts3,
                    b_r,
                    @as(usize, @abs(self.width)),
                    TAL,
                );
                _ = tl.textLine(ts4).draw();
            }
        } else {
            if (self.parent) |_| {
                const t_line = stringAlign(
                    &tl_buffer_1,
                    "",
                    ' ',
                    @as(usize, @abs(self.width)) - 2,
                    TextAlign.Left,
                );
                _ = tl.textLine(t_line).draw();
            }
        }
    }

    /// Draw the panes
    pub fn draw(self: *Self) *Self {
        _ = self.update();
        if (self.parent == null) {
            _ = Term.clearScreen(self.writer);
        }
        if ((self.width >= self.minimum_width) and //
            (self.height >= self.minimum_height))
        {
            self.drawFrame();
            // const hh = @as(usize, @abs(self.height)); // + 1;
            // for (0..hh) |row| {
            //     self.drawRow(row);
            // }
            if (self.render_text_next) |r_text| {
                // const r_text = self.render_text_next.?;
                _ = r_text.draw();
                if (self.writer.list.len > 3072) {
                    _ = self.writer.flush() catch unreachable;
                }
            }
            if (self.render_array_next) |r_text| {
                // const r_text = self.render_array_next.?;
                _ = r_text.draw();
                if (self.writer.list.len > 3072) {
                    _ = self.writer.flush() catch unreachable;
                }
            }
        }
        _ = self.writer.flush() catch unreachable;
        // Draw other siblings
        if (self.sibling_next) |n| {
            _ = n.draw();
            if (self.writer.list.len > 3072) {
                _ = self.writer.flush() catch unreachable;
            }
        }
        // Draw the "children"
        if (self.child_head) |current_child| {
            _ = current_child.draw();
            if (self.writer.list.len > 3072) {
                _ = self.writer.flush() catch unreachable;
            }
        }
        _ = self.writer.flush() catch unreachable;
        return self;
    }
};
