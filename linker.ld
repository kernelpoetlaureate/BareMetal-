// Simple minimal kernel

void main() {

    // Very basic VGA output

    volatile char* video = (volatile char*)0xB8000;

    

    // Clear screen

    for (int i = 0; i < 80 * 25 * 2; i += 2) {

        video[i] = ' ';

        video[i + 1] = 0x07;  // Light gray on black

    }

    

    // Simple message

    char* msg = "C Kernel Running!";

    for (int i = 0; msg[i] != '\0'; i++) {

        video[i * 2] = msg[i];

        video[i * 2 + 1] = 0x0F;  // White on black

    }

    

    // Hang

    while(1) {

        asm volatile ("hlt");

    }

}



