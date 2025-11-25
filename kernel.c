// kernel.c

// KEINE globale Variable mehr!
// Wir definieren VIDEO_MEM als Konstante.
#define VIDEO_MEM ((volatile char*)0xB8000)

void kmain() {
    // Endlosschleife, um sicherzugehen, dass wir hier bleiben
    // und nicht in den Speicher dahinter fallen.
    
    // Fülle den ganzen Screen blau mit 'X'
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        VIDEO_MEM[i] = 'X';
        VIDEO_MEM[i+1] = 0x1F; // Blau
    }
    
    // Test: Ein rotes "A" ganz am Anfang, falls die Schleife versagt
    VIDEO_MEM[0] = 'A';
    VIDEO_MEM[1] = 0x4F; // Rot auf Weiß
    
    while(1);
}