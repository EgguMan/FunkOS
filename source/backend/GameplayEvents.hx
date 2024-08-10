package backend;

import flixel.util.FlxSignal;
import object.note.*;

class GameplayEvents {
    #if AeroEvents

    //this shit REEKS of clientprefs.hx but 1. I am not writing a macro and 2. I am not using reflect.

    //I fear for those who will try to mod this, luck is not in your favor
    //                  -eggu

    public static var NOTE_HIT:FlxTypedSignal<Note->Void>;
    public static var NOTE_MISS:FlxTypedSignal<Note->Void>;

    public static var CONDUCTOR_BEAT:FlxTypedSignal<Int->Void>;
    public static var CONDUCTOR_STEP:FlxTypedSignal<Int->Void>;
    public static var CONDUCTOR_SECTION:FlxTypedSignal<Int->Void>;

    public static var GAME_UPDATE:FlxTypedSignal<Float->Void>;
    public static var GAME_PLAYUPDATE:FlxTypedSignal<Bool->Void>; // if the game has been pause, or resumed. True = pause


    public static function init() {
        if (NOTE_HIT != null) {
            NOTE_HIT.removeAll();
            NOTE_MISS.removeAll();

            CONDUCTOR_BEAT.removeAll();
            CONDUCTOR_STEP.removeAll();
            CONDUCTOR_SECTION.removeAll();

            GAME_UPDATE.removeAll();
            GAME_PLAYUPDATE.removeAll();
        } else {
            NOTE_HIT = new FlxTypedSignal<Note->Void>();
            NOTE_MISS = new FlxTypedSignal<Note->Void>();
    
            CONDUCTOR_BEAT = new FlxTypedSignal<Int->Void>();
            CONDUCTOR_STEP = new FlxTypedSignal<Int->Void>();
            CONDUCTOR_SECTION = new FlxTypedSignal<Int->Void>();
            
            GAME_UPDATE = new FlxTypedSignal<Float->Void>();
            GAME_PLAYUPDATE = new FlxTypedSignal<Bool->Void>();
        }
        
    }
    #end
}