// Simple minimal kernel - FIXED VERSION
void _start() {
    // Very basic VGA output
    volatile char* video = (volatile char*)0xB8000;
    
    // Simple message - don't clear entire screen initially
    char* msg = "C Kernel Works!";
    for (int i = 0; msg[i] != '\0'; i++) {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x0F;  // White on black
    }
    
    // Hang
    while(1) {
        asm volatile ("hlt");
    }
}