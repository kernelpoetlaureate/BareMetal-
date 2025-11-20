void main() {
    char* video_memory = (char*)0xb8000;
    char* str = "gamarjoba";
    
    int i = 0;
    while (str[i] != 0) {
        video_memory[i * 2] = str[i];      // Character
        video_memory[i * 2 + 1] = 0x0f;    // Attribute (White on Black)
        i++;
    }
}
