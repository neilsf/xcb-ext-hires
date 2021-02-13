rem **************************************
rem * xcb-ext-hires                      *
rem *                                    *
rem * A Graphics Extension for XC-BASIC  *
rem * C64 320x200 Monochrome Hiresmode   *
rem *                                    *
rem * (c) by THOMAS MARKL, 2020          *
rem * Licence: Freeware                  *
rem *                                    *
rem * Optimizations, reformatted code,   *
rem * VIC bank relocation, fill algoritm *
rem * by CSABA FEKETE                    *
rem *                                    *
rem * Namespace: hi_                     *
rem **************************************

rem **************************************
rem * Color constants
rem **************************************

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

const HI_BITMAPADDR = $a000
const HI_SCREENADDR = $8c00

rem **************************************
rem * Reserved variables
rem **************************************

data hi_bitmask![] = 128, 64, 32, 16, 8, 4, 2, 1
dim  hi_z[25]

rem **************************************
rem * Command
rem * hi_bitmapon
rem *
rem * Turns on bitmap screen mode 
rem **************************************

proc hi_bitmapon
  rem -- VIC sees bank 2
  poke $dd00, (peek!($dd00) & %11111100) | %00000001
  rem -- Bitmap RAM at $a000, Screen RAM at $8c00
  poke $d018, %00111010
  rem -- Bitmap mode on
  poke $d011, peek!($d011) | %00100000
  rem -- Multicolor mode off
  poke $d016, peek!($d016) & %11101111
  rem -- create lookup tables
  addr = \HI_BITMAPADDR
  for i! = 0 to 24
    \hi_z[i!] = addr
    addr = addr + 320
  next i!
endproc

rem **************************************
rem * Command
rem * hi_bitmapoff
rem *
rem * Turns off bitmap screen mode
rem **************************************

proc hi_bitmapoff
  rem -- Bitmap mode off
  poke $d011, peek!($d011) & %11011111
  rem -- Restore screen address to default
  poke $d018, %00010101
  rem -- Switch VIC to bank 0
  poke $dd00, peek!($dd00) | %00000011
endproc

rem **************************************
rem * Command
rem * hi_clear
rem *
rem * Clear bitmap
rem **************************************

proc hi_clear
  memset \HI_BITMAPADDR, 8000, 0
endproc

rem **************************************
rem * Command
rem * hi_setcolor
rem *
rem * Sets ink and background color
rem * Arguments:
rem * inkcol! - Ink color (0-15)
rem * bgcol!  - Background color (0-15)
rem **************************************

proc hi_setcolor(inkcol!, bgcol!)
  f! = lshift!(inkcol!, 4) | bgcol!
  memset \HI_SCREENADDR, 1000, f!
endproc

rem **************************************
rem * Command
rem * hi_dot
rem * Draws a single dot
rem * 
rem * Arguments:
rem * x, y! - Dot coordinates
rem **************************************

proc hi_dot(x, y!)
  g = \hi_z[rshift!(y!, 3)] + (x & 504) + (y! & 7)
  poke g, peek!(g) | \hi_bitmask![cast!(x) & 7]
endproc

rem **************************************
rem * Function
rem * hi_dotset!
rem * Checks if a dot on bitmap is set
rem * 
rem * Arguments:
rem * x, y! - Dot coordinates
rem * Returns 0 if unset, 1 if set
rem **************************************

fun hi_dotset!(x, y!)
  g = \hi_z[rshift!(y!, 3)] + (x & 504) + (y! & 7)
  if peek!(g) & \hi_bitmask![cast!(x) & 7] > 0 then return 1 else return 0
endfun

rem ******************************
rem * Command
rem * hi_line
rem * Draws a line
rem * 
rem * Arguments:
rem * x1, y1 - Start coordinates
rem * x2, y2 - End coordinates
rem ******************************

proc hi_line(x1, y1, x2, y2)
  dx = x2 - x1
  dy = y2 - y1
  xstep = 1
  ystep = 1
  x = x1
  y = y1
 
  if dx < 0 then 
    dx = dx*(-1)
    xstep = xstep*(-1)
  endif
 
  if dy < 0 then 
    dy = dy*(-1)
    ystep = ystep*(-1)
  endif
 
  a = lshift(dx, 2)
  b = lshift(dy, 2)
 
  if dy <= dx then
    f = dx*(-1)
    while x <> x2
     hi_dot x, y
     f = f + b
     if f > 0 then
      y = y + ystep
      f = f - a
     endif
     x = x + xstep
    endwhile
  else
    f = dy*(-1)
    while y <> y2
      hi_dot x, y
      f = f + a
      if f > 0 then
        x = x + xstep
        f = f - b
      endif
      y = y + ystep
    endwhile
  endif
  hi_dot x, y
endproc

rem ******************************
rem * Command
rem * hi_box
rem * Draws a filled rectangle
rem * 
rem * Arguments:
rem * x1, y1 - Start coordinates
rem * x2, y2 - End coordinates
rem ******************************

proc hi_box(x1, y1, x2, y2)
  for y = y1 to y2
    hi_line x1, y, x2, y
  next y
endproc

rem ******************************
rem * Command
rem * hi_rect
rem * Draws an empty rectangle
rem * 
rem * Arguments:
rem * x1, y1 - Start coordinates
rem * x2, y2 - End coordinates
rem ******************************

proc hi_rect(x1, y1, x2, y2)
  hi_line x1, y1, x2, y1
  hi_line x1, y1, x1, y2
  hi_line x2, y1, x2, y2
  hi_line x1, y2, x2, y2
endproc

rem ******************************
rem * Command
rem * hi_circle
rem * Draws a circle
rem * 
rem * Arguments:
rem * xM, yM - Coordinates of centre point
rem * r      - Radius
rem ******************************
proc hi_circle(xM, yM, r)
  if xM - r < 0 then xM = r
  if xM + r > 319 then xM = 319 - r
  if yM - r < 0 then yM = r 
  if yM + r > 199 then yM = 199 - r

  x = 0
  y = r
  delta = 3 - LSHIFT(r, 2)

  hi_dot xM, yM + r
  hi_dot xM, yM - r
  hi_dot xM + r, yM
  hi_dot xM - r, yM

  while x < y
     if delta >= 0 then
        delta = delta + LSHIFT((x-y), 2) + 10
      dec y
     else
        delta = delta + LSHIFT(x, 2) + 6
     endif
     inc x
     hi_dot xM + x, yM + y
     hi_dot xM + x, yM - y
     hi_dot xM - x, yM + y
     hi_dot xM - x, yM - y
     hi_dot xM + y, yM + x
     hi_dot xM + y, yM - x
     hi_dot xM - y, yM + x
     hi_dot xM - y, yM - x
  endwhile 
endproc

rem ******************************
rem * Command
rem * hi_fill
rem * Fills a closed area
rem * 
rem * Arguments:
rem * x, y! - Coordinates of starting point
rem ******************************

proc hi_fill(x, y!)
  if hi_dotset!(x, y!) <> 0 then return
  rem -- use the stack from bottom up
  dim xq[32] @ $0100
  dim yq![32] @ $0140
  qptr! = 0
  xq[qptr!] = x
  yq![qptr!] = y!
  inc qptr!
  while qptr! > 0
    xnext = xq[0]
    ynext! = yq![0]
    xnsave = xnext + 1
    ynsave! = ynext!
    memcpy @xq + 2, @xq, lshift!(qptr! - 1)
    memcpy @yq! + 1, @yq!, qptr! - 1
    dec qptr!

    rem -- draw left
    dir! = 0
    gosub sub_draw

    rem -- draw right
    xnext = xnsave
    ynext! = ynsave!
    dir! = 1
    gosub sub_draw
    ''loop: goto loop
  endwhile
  return
  
  sub_draw:
    hit_up! = 0
    hit_dn! = 0
    while hi_dotset!(xnext, ynext!) = 0
      hi_dot xnext, ynext!
      
      rem -- check upper
      if hi_dotset!(xnext, ynext! - 1) = 0 then
        if hit_up! = 0 then
          rem -- push
          xq[qptr!] = xnext
          yq![qptr!] = ynext! - 1
          inc qptr!
          hit_up! = 1
        endif
      else
        hit_up! = 0
      endif
      
      rem -- check lower
      if hi_dotset!(xnext, ynext! + 1) = 0 then
        if hit_dn! = 0 then
          rem -- push
          xq[qptr!] = xnext
          yq![qptr!] = ynext! + 1
          inc qptr!
          hit_dn! = 1
        endif
      else
        hit_dn! = 1
      endif

      
      if dir! = 0 then dec xnext else inc xnext
    endwhile
    return
endproc