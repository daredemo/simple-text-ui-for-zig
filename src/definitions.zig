pub const tcflag_t = c_uint;
pub const speed_t = c_uint;
pub const cc_t = u8;
pub const struct_termios = extern struct {
    c_iflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_oflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_cflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_lflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_line: cc_t = @import("std").mem.zeroes(cc_t),
    c_cc: [32]cc_t = @import("std").mem.zeroes([32]cc_t),
    c_ispeed: speed_t = @import("std").mem.zeroes(speed_t),
    c_ospeed: speed_t = @import("std").mem.zeroes(speed_t),
};
pub const struct_winsize = extern struct {
    ws_row: c_ushort = @import("std").mem.zeroes(c_ushort),
    ws_col: c_ushort = @import("std").mem.zeroes(c_ushort),
    ws_xpixel: c_ushort = @import("std").mem.zeroes(c_ushort),
    ws_ypixel: c_ushort = @import("std").mem.zeroes(c_ushort),
};
pub extern fn set_signal() void;
pub extern fn save_terminal_settings() struct_termios;
pub extern fn restore_terminal_settings(arg_oldt: struct_termios) void;
pub extern fn disable_echo_and_canonical_mode(arg_state: [*c]struct_termios) void;
// pub extern fn get_terminal_size() struct_winsize;
pub const sig_atomic_t = c_int;
pub extern var win_width: sig_atomic_t;
pub extern var win_heidht: sig_atomic_t;
pub extern fn setup_sigint() void;
pub extern fn setup_sigwinch() void;
pub extern fn handle_sigwinch(sig: c_int) void;
