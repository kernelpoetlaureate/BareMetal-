void kmain() {
    volatile char* video = (volatile char*)0xB8000;
    
    char* text1 = "Hallo Welt";

    // Text 1 in Zeile 0 schreiben
    int i = 0;
    int offset1 = 0;
    while(text1[i] != 0) {
        video[offset1] = text1[i];
        video[offset1+1] = 0x0F;
        offset1 += 2;
        i++;
    }

    while(1);

}

