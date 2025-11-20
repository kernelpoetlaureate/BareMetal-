// Memory map constants
#define MEMORY_MAP_SIZE 1024  // 1KB
#define BLOCK_SIZE 16         // Each block is 16 bytes
#define NUM_BLOCKS (MEMORY_MAP_SIZE / BLOCK_SIZE)  // 64 blocks

// Memory pool - 1KB of memory we'll manage
char memory_pool[MEMORY_MAP_SIZE];

// Bitmap to track which blocks are allocated (1 = allocated, 0 = free)
// We need 64 bits for 64 blocks, so 8 bytes
unsigned char allocation_map[NUM_BLOCKS / 8];

// Helper function to print a character to screen
void print_char(char c, int row, int col) {
    char* video_memory = (char*)0xb8000;
    int offset = (row * 80 + col) * 2;
    video_memory[offset] = c;
    video_memory[offset + 1] = 0x0f;  // White on black
}

// Helper function to print a string at a position
void print_at(char* str, int row, int col) {
    int i = 0;
    while (str[i] != 0) {
        print_char(str[i], row, col + i);
        i++;
    }
}

// Helper to convert number to hex string
void int_to_hex(unsigned int num, char* buffer) {
    const char hex_chars[] = "0123456789ABCDEF";
    buffer[0] = '0';
    buffer[1] = 'x';
    for (int i = 7; i >= 0; i--) {
        buffer[2 + (7 - i)] = hex_chars[(num >> (i * 4)) & 0xF];
    }
    buffer[10] = 0;
}

// Initialize memory map
void init_memory_map() {
    // Clear allocation map (all blocks free)
    for (int i = 0; i < NUM_BLOCKS / 8; i++) {
        allocation_map[i] = 0;
    }
}

// Allocate a block of memory
void* allocate_block() {
    for (int i = 0; i < NUM_BLOCKS; i++) {
        int byte_index = i / 8;
        int bit_index = i % 8;
        
        // Check if block is free
        if (!(allocation_map[byte_index] & (1 << bit_index))) {
            // Mark as allocated
            allocation_map[byte_index] |= (1 << bit_index);
            // Return pointer to the block
            return (void*)(&memory_pool[i * BLOCK_SIZE]);
        }
    }
    return 0;  // No free blocks
}

// Free a block of memory
void free_block(void* ptr) {
    // Calculate which block this pointer refers to
    int offset = (char*)ptr - memory_pool;
    if (offset < 0 || offset >= MEMORY_MAP_SIZE) {
        return;  // Invalid pointer
    }
    
    int block_num = offset / BLOCK_SIZE;
    int byte_index = block_num / 8;
    int bit_index = block_num % 8;
    
    // Mark as free
    allocation_map[byte_index] &= ~(1 << bit_index);
}

// Display memory map status
void display_memory_map() {
    print_at("Memory Map (1KB, 16-byte blocks):", 0, 0);
    
    char buffer[11];
    
    // Show memory pool address
    print_at("Pool addr:", 2, 0);
    int_to_hex((unsigned int)memory_pool, buffer);
    print_at(buffer, 2, 12);
    
    // Show allocation status
    print_at("Blocks: [F=Free, A=Allocated]", 4, 0);
    
    int row = 6;
    int col = 0;
    for (int i = 0; i < NUM_BLOCKS; i++) {
        int byte_index = i / 8;
        int bit_index = i % 8;
        
        char status = (allocation_map[byte_index] & (1 << bit_index)) ? 'A' : 'F';
        print_char(status, row, col);
        
        col++;
        if (col >= 64) {
            col = 0;
            row++;
        }
    }
}

void main() {
    // Initialize the memory management system
    init_memory_map();
    
    // Display initial state
    display_memory_map();
    
    // Test: Allocate some blocks
    void* block1 = allocate_block();
    void* block2 = allocate_block();
    void* block3 = allocate_block();
    
    // Update display
    display_memory_map();
    
    // Show allocated addresses
    char buffer[11];
    print_at("Allocated blocks:", 10, 0);
    
    int_to_hex((unsigned int)block1, buffer);
    print_at("Block1:", 11, 0);
    print_at(buffer, 11, 8);
    
    int_to_hex((unsigned int)block2, buffer);
    print_at("Block2:", 12, 0);
    print_at(buffer, 12, 8);
    
    int_to_hex((unsigned int)block3, buffer);
    print_at("Block3:", 13, 0);
    print_at(buffer, 13, 8);
    
    // Infinite loop
    while(1);
}

