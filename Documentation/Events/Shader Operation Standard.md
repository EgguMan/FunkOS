# Shader Operation Standard

## what is the Shader Operation Standard?

The Shader Operation Standard (SOS) is a way to customize and use shader events in Aero Engine. Any event added via the "Shader Events" Tab in the charting screen will use this standard as its value input instead of value 1 and 2. 

## How do you use the Shader Operation Standard?

The SOS is formatted as follows, `valueName: value, valueName: value`. There is no proper order for value names, and capitalization or spaces do not matter. All that matters is that you input a valid value name, value, and use colons / commas as necessary. Colons are used to space values apart or mark the end of a value name. For example, in the 4 component `color` value of the Color Contrast event, you would format it as so. `colors: 0xFFFFFFFF : 0xFFFFFFFF : 0xFFFFFFFF : 0xFFFFFFFF`.   Commas are used to define a new value, for example, `colors: 0xFFFFFFFF, speed: 0.5`. All valid value names are listed below, but do note, if an event's description does not state that it is used, it will not be used.

`"Size",
"Bool" or "Boolean",
"Time",
"Target" or "Camera",
"Intensity" or "Value" or "Speed",
"Color" or "Colors" or "Colour" or "Colours"`

## edge cases

If you edit a value that does not exist then you will be told in the log or command prompt. If a value is needed, but is not set, then the code will set it to a default. The default values change for each event, and for some shaders like the viginette it will change every time you use it (0.45 -> 0 -> 0.45 -> 0)
