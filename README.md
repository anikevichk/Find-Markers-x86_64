# Description of find_markers.asm

This assembly code is designed to locate markers within a BMP image. It utilizes image traversal algorithms to identify specific segments (markers) and stores their coordinates in arrays `xArrayPtr` and `yArrayPtr`.

## Functions and Key Components

### `find_markers`

The main function `find_markers` takes the following arguments:
- `bmp` - pointer to the beginning of the BMP image.
- `xArrayPtr`, `yArrayPtr` - pointers to arrays where marker coordinates will be stored.
- `width`, `height` - width and height of the image respectively.
- `amount` - number of markers found (up to 50).
- `checkLength`, `counter`, `cx`, `cy`, `myflags` - registers and variables used for controlling the search process.

### Image Processing

The marker detection algorithm involves the following stages:
1. **Traversal through Width and Height of the Image**:
   - Nested loops `width_loop` and `height_loop` iterate over all pixels.

2. **Marker Detection and Verification**:
   - Various functions (`walk_left_black`, `walk_down_white`, etc.) are used to check if the current segment matches marker conditions.
   - If conditions are met, the marker coordinates are saved in `xArrayPtr` and `yArrayPtr`.
   - Maximum number of markers is limited to 50 (`cmp rax, 50`).
### Steps to Build

1. **Clone the Repository**: Clone the repository containing the code.
2. **Setup Environment**: Ensure NASM and necessary compilers are installed and configured.
3. **Build**: Use the `make` utility to build the project.
   
   ```bash
   make
   ./app  ```
