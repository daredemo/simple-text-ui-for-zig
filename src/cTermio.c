#include <asm-generic/ioctls.h>
#include <sys/ioctl.h>
#include <termio.h>
#include <termios.h>
#include <unistd.h>
#include <signal.h>


// zig translate-c -static src/cTermio.c -lc > src/cTermio.zig

volatile sig_atomic_t win_width = 0;
volatile sig_atomic_t win_height = 0;

// Handler to ignore signals
// void signal_handler(int sig){}
void handleSigint(const int sig) {}

void handleSigwinch(const int sig) {
    struct winsize w;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0) {
        win_width = w.ws_col;
        win_height = w.ws_row;
    }
}


// Function to save terminal settings
struct termios saveTerminalSettings() {
    struct termios oldt;
    tcgetattr(STDIN_FILENO, &oldt);
    return oldt;
}

// Function to restore terminal settings
void restoreTerminalSettings(struct termios oldt) {
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

void disableEchoAndCanonicalMode(struct termios* state) {
    state->c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, state);
}

// Ignore SIGINT
void setSignal(){
    // signal(SIGINT, signal_handler);
    signal(SIGINT, handleSigint);
    signal(SIGWINCH, handleSigwinch);
}

// struct winsize get_terminal_size() {
//     struct winsize w;
//     ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
//     return w;
// }
//
// // Migration to `sigaction`
// void setup_sigint() {
//     struct sigaction sa;
//     sa.sa_handler = handleSigint;
//     sigemptyset(&sa.sa_mask);
//     sa.sa_flags = 0;
//     sigaction(SIGINT, NULL, &sa);
// }
//
// void setup_sigwinch() {
//     struct sigaction sa;
//     sa.sa_handler = handleSigint;
//     sigemptyset(&sa.sa_mask);
//     sa.sa_flags = 0;
//     sigaction(SIGWINCH, NULL, &sa);
// }
