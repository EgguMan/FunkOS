package backend.events;

/*
    This is a template event! Feel free to use it as a template, or to reference it!

    This event will remember a character's according number from Playstate when its called, then trace the character's name when
    the event is ran!

    Bf is 0, Dad is 1, and GF is 2!
*/


class TemplateEvent {  
    public static var characters:Array<String> = []; // where the names will be held
    public static var iteration:Int = 0; // the current place in the array

    static final characterNames:Array<String> = ['Boyfriend', 'Daddy Dearest', 'Girlfriend']; // having a list of characters is easier than running a switch or if statement

    public static function reset() { // automatically run, very important and should exist if your event stores data
        iteration = 0; // start from the beginning
        characters = []; // clear, incase the events have been edited or a new event was placed
    }

    public static function pushNewCharacter(char:String) { // this is when the event is first called. Events use a String input system, so you need to accept a string input or process it before its called
        
        if (!EventsCore.classes.contains(TemplateEvent)) {
            EventsCore.classes.push(TemplateEvent); // add this to the reset queue so it is automatically reset
        }

        var characterInteger = Std.parseInt(char); // Std.parseInt will look for a number inside of the char string.

        if (Math.isNaN(characterInteger)) {
            characterInteger = 0; // if the char string is blank, then Std.parseInt will return an integer value called NaN, Not a Number, just to be sure we check if this is the case.
        }
        

        characters.push(characterNames[iteration]); // add it to the array
    }

    public static function traceNewCharacter() {
        trace(characters[iteration]); // trace the current character

        iteration++; // increase the index by 1
    }
}