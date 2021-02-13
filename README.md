# xcb-ext-hires

A hi-res graphics extension for XC=BASIC originally written by Thomas Markl. Compatible with XC=BASIC v2.2.10 or higher. [Click here to learn about XC=BASIC](https://xc-basic.net)

# Usage

Include the file `xcb-ext-hires.bas` in the top of your program:

    include "path/to/xcb-ext-hires.bas"
    
That's it, you can now use all the symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `hi_` in your program.

# Examples

Refer to the file *examples/demo.bas* for an example.

# Quick reference

The extension adds a few commands to XC=BASIC that you can use to switch to bitmap mode, draw on the bitmap and return to text mode. Here is a brief description of the commands:

## hi_bitmapon

Usage:

    hi_bitmapon

Turns on bitmap mode. The command will switch VIC-II to use Bank 2, that is, $8000-$bfff. The bitmap will be placed at $a000-$bf3f and the screen RAM will be placed at $8c00-7fe7.
You can use the following constants if you need a pointer to these locations:

    const HI_BITMAPADDR = $a000
    const HI_SCREENADDR = $8c00

## hi_setcolor

Usage:

    hi_setcolor <ink_color>, <background_color>

Sets color for drawing. You can use the following constants for colors:

    const HI_BLACK!       = 0
    const HI_WHITE!       = 1
    const HI_RED!         = 2
    const HI_CYAN!        = 3
    const HI_PURPLE!      = 4
    const HI_GREEN!       = 5
    const HI_BLUE!        = 6
    const HI_YELLOW!      = 7
    const HI_ORANGE!      = 8 
    const HI_BROWN!       = 9
    const HI_LIGHTRED!    = 10
    const HI_DARKGRAY!    = 11
    const HI_MIDDLEGRAY!  = 12
    const HI_LIGHTGREEN!  = 13
    const HI_LIGHTBLUE!   = 14
    const HI_LIGHTGRAY!   = 15

## hi_clear

Usage:

    hi_clear

Clears the entire bitmap by setting all pixels to background color.

## hi_dot

Usage:

    hi_dot <x>, <y>

Draws a single dot by setting a pixel to the ink color. The top left corner of the screen is (0,0) and the bottom right is (319,199).

**WARNING: For performance reasons, there is no sanity check for the arguments passed in. If you pass arguments that are out of the screen bounds, the behaviour will be undefined without any warning or error emitted. This is true for all the commands in this extension.**

## hi_dotset

Usage:

    x = hi_dotset!(<x>, <y>)

or:

    if hi_dotset!(<x>, <y>) = 1 then <statement>

This is a function that returns 1 if the pixel at <x>, <y> is set, 0 otherwise.

## hi_line

Usage:

    hi_line <x1>, <y1>, <x2>, <y2>

Draws a line between (<x1>,<y1>) and (<x2>,<y2>).

## hi_rect

Usage:

    hi_rect <x1>, <y1>, <x2>, <y2>

Draws a rectangle between (<x1>,<y1>) and (<x2>,<y2>).

## hi_box

Usage:

    hi_box <x1>, <y1>, <x2>, <y2>

Draws a filled rectangle between (<x1>,<y1>) and (<x2>,<y2>).

## hi_circle

Usage:

    hi_circle <x>, <y>, <r>

Draws a circle with center point (<x>,<y>) and radius <r>.

## hi_fill

Usage:

    hi_fill <x>, <y>

Flood fills a closed area starting from point (<x>,<y>).

**WARNING: this command can only fill an area that's fully closed. If filling hits the border, the behaviour will be undefined.**

# To do

The following things are yet to be implemented. Feel free to contribute!

  - Erasing
  - Drawing ellpises and arcs
  - Writing chars on bitmap
  - Copying sprites onto bitmap
  - 