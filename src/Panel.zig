const std = @import("std");

pub const Layout = enum {
    Horizontal,
    Vertical,
};

pub const Panel = struct {
    title: ?[]const u8 = undefined,
    parent_width: *i32 = undefined,
    parent_height: *i32 = undefined,
    width: i32 = undefined,
    height: i32 = undefined,
    layout: Layout = undefined,
    parent: ?*Panel = undefined,
    child_head: ?*Panel = undefined,
    sibling_next: ?*Panel = undefined,
    size_absolute: ?f32 = undefined,
    size_relative: ?f32 = undefined,
    allocator: *std.mem.Allocator = undefined,

    pub fn init(title: ?[]u8, parent: *Panel, layout: Layout, allocator: *std.mem.Allocator) *Panel {
        const panel = allocator.create(Panel) catch unreachable;
        panel.* = Panel{
            .title = title,
            .parent = parent,
            .layout = layout,
            .allocator = allocator,
            .parent_width = parent.width.*,
            .parent_height = parent.height.*,
            .width = @as(i32, 0),
            .height = @as(i32, 0),
            .child_head = null,
            .sibling_next = null,
            .size_absolute = null,
            .size_relative = null,
        };
        if (layout == Layout.Vertical) {
            panel.width = parent.width.*;
        } else {
            panel.height = parent.height.*;
        }
        return panel;
    }

    pub fn init_root(title: ?[]u8, parent_w: *i32, parent_h: *i32, layout: Layout, allocator: *std.mem.Allocator) *Panel {
        const panel = allocator.create(Panel) catch unreachable;
        panel.* = Panel{
            .title = title,
            .parent = null,
            .layout = layout,
            .allocator = allocator,
            .parent_width = parent_w,
            .parent_height = parent_h,
            .width = @as(i32, 0),
            .height = @as(i32, 0),
            .child_head = null,
            .sibling_next = null,
            .size_absolute = null,
            .size_relative = null,
        };
        panel.width = parent_w.*;
        panel.height = parent_h.*;
        return panel;
    }

    pub fn update(self: *Panel) *Panel {
        if (self.parent == null) {
            self.width = self.parent_width.*;
            self.height = self.parent_height.*;
        } else {
            if (self.layout == Layout.Vertical) {
                self.width = self.parent.?.width;
            } else {
                self.height = self.parent.?.height;
            }
        }
        if (self.sibling_next != null) {
            _ = self.sibling_next.?.update();
        }
        if (self.child_head != null) {
            _ = self.child_head.?.update();
        }
        return self;
    }
};
