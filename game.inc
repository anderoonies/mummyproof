;;Library functions
MouseInfo STRUCT
    horiz DWORD ?
    vert DWORD ?
    buttons DWORD ?
MouseInfo ENDS

Sprite STRUCT
    bitmapPtr DWORD ?
    dwHeight DWORD ?
    dwWidth DWORD ?
    visible BYTE 1
    x DWORD ?
    y DWORD ?
    direction DWORD 0
    cycle DWORD 0
    angle FXPT 1
    speed DWORD 20
Sprite ENDS

MK_CONTROL  = 0008h
MK_LBUTTON  = 0001h
MK_MBUTTON  = 0010h
MK_RBUTTON  = 0002h
MK_SHIFT    = 0004h
MK_XBUTTON1 = 0020h
MK_XBUTTON2 = 0040h

BlackStarField PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

GameInit PROTO
GamePlay PROTO
MoveSprite PROTO sprite:PTR Sprite, direction:DWORD
UpdateMummyBitmap PROTO mummyPtr:PTR Sprite, cycle:DWORD
UpdateExplosionBitmap PROTO explosionPtr:PTR Sprite, cycle:DWORD
ShootFireBall PROTO fireball:PTR Sprite, y:DWORD
LevelUp PROTO
GameOver PROTO
GiveSword PROTO
KillMummies PROTO
UpdateCycle PROTO sprite:PTR Sprite, numCycles:DWORD