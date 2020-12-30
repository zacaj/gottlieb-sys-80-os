# gottlieb-sys-80-os
custom operating system for Gottlieb System 80/A/B pinball machines

## Current Status
Currently can make a playable game, but features/polish is limited, focusing on trying to get a complete game coded (Diamond Lady).  If you're interested in the project, send me an email (gh@zacaj.com)!
 
### Supported 
- lamps: can drive all lamps, supports single speed blinking
- coils: can drive all coils, including external coils controlled via lamps
- displays: 80B alphanumeric displays supported, 80/A numeric still in progress
- sound: can send commands using S1-16
- switches: scans matrix with 2-pass settling (like Bally used), calls different switch routines based on a table
- simple 'threading' via sleep commands, allowing other switches to be serviced (no stack, however)
- adding scores, starting games, cycling through balls

### Not supported
- high scores, audits
- subtracting scores
- coin logic
- dip switch reading
- configurable switch settle timing

## Usage
- (windows only)
- edit build.bat to point to your game's source file
- run build.bat
- run do.bat
- pinmame should open

