#include <asm-generic/ioctls.h>
#include <sys/ioctl.h>
#include <termio.h>
#include <termios.h>
#include <unistd.h>
#include <signal.h>

// zig translate-c -static src/cTermio.c -lc > src/cTermio.zig

// Handler to ignore signals
void signal_handler(int sig){}

// Function to save terminal settings
struct termios save_terminal_settings() {
    struct termios oldt;
    tcgetattr(STDIN_FILENO, &oldt);
    return oldt;
}

// Function to restore terminal settings
void restore_terminal_settings(struct termios oldt) {
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

void disable_echo_and_canonical_mode(struct termios* state) {
    state->c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, state);
}

// Ignore SIGINT
void set_signal(){
    signal(SIGINT, signal_handler);
}

struct winsize get_terminal_size() {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    return w;
}
