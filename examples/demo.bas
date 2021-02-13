
rem **************************************
rem * A TESTPROGRAM FOR                  *
rem * xcb-ext-hires Version 0.1          *
rem *                                    *
rem * A Graphics Extension for XC=BASIC  *
rem * C64 320x200 Monochrome Hiresmode   *
rem *                                    *                                  
rem * (c) by THOMAS MARKL, 2020          *
rem * Licence: Freeware                  *
rem **************************************

include "../xcb-ext-hires.bas"

hi_bitmapon
hi_setcolor 7, 4
hi_clear

for i=0 to 95
  hi_line 5,5+2*i,314,194-2*i
next i

repeat : until inkey!() <> 0
hi_clear
hi_setcolor 2, 1

for i=8 to 60 step 2
hi_rect i,i,319-i,199-i
next i

repeat : until inkey!() <> 0
hi_clear
hi_setcolor 6, 15

for r! = 0 to 95 step 5
  hi_circle 160, 100, r!
next

for y! = 102 to 192 step 10
  hi_fill 160, y!
next y!

repeat : until inkey!() <> 0
hi_bitmapoff