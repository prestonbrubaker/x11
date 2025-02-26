#include <X11/Xlib.h>
#include <stdio.h>
#include <string.h>

int main() {
    Display *d = XOpenDisplay(NULL);
    if (!d) {
        printf("Failed to open display\n");
        return 1;
    }
    
    Window known_root = DefaultRootWindow(d);
    printf("Actual root: 0x%lx\n", known_root);
    
    // Search deeper in the Display structure
    unsigned char *display_memory = (unsigned char *)d;
    const size_t SEARCH_SIZE = 16384;  // 16KB search range
    
    for (size_t offset = 0; offset < SEARCH_SIZE; offset += sizeof(long)) {
        Window candidate = *(Window*)(display_memory + offset);
        
        if (candidate == known_root) {
            printf("Found root window at offset: 0x%lx\n", offset);
            XCloseDisplay(d);
            return 0;
        }
    }
    
    printf("Root window not found in first 16KB\n");
    XCloseDisplay(d);
    
    // Try Screen structure offsets as fallback
    Screen *screen = DefaultScreenOfDisplay(d);
    printf("Try these common Screen* offsets:\n");
    printf("Screen.root offset: %ld\n", (char*)&screen->root - (char*)screen);
    
    return 1;
}
