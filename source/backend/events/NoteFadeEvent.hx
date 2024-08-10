package backend.events;

import states.PlayState;
import flixel.util.helpers.FlxBounds;
import flixel.tweens.FlxTween;

class NoteFadeEvent {
    public static var vals:Array<Array<Float>> = [];
    public static var iteration:Int = 0;
    public static var last:Array<Bool> = [true,true ];
    public static function reset() {
        iteration = 0;
        vals = [];
        last = [true,true];
    }

    public static function pushed() {
        if (!EventsCore.classes.contains(NoteFadeEvent)) EventsCore.classes.push(NoteFadeEvent);
    }

    public static function fadeNotes() { // why are you not done oncreate? i probably did this for a reason so i wont fw it
        var note = vals[iteration][0];
        var range:FlxBounds<Int>;
        trace(note);
        switch(note) {
            case 0:
                range = new FlxBounds(0, 4);
            case 1:
                range = new FlxBounds(4, 8);
            default:
                range = new FlxBounds(0, 8);
        }
        var targetAlpha:Int = 0;
        if (note >= 2) 
            last = [!last[0], !last[1]];
         else 
            last[Std.int(Math.min(note, 2))] = !last[Std.int(Math.min(note, 1))];

        if ((last[Std.int(Math.min(note, 1))])) 
            targetAlpha = 1;
        

        for (i in range.min...range.max) {
            var member = PlayState.instance.strumLineNotes.members[i];
            if (vals[iteration][1] <= 0) {
                member.alpha = targetAlpha;
            } else {
                var tweenName = 'NoteFadeEventTween$note$iteration';
                PlayState.instance.runningTweens.set(tweenName, FlxTween.tween(member, {alpha:targetAlpha}, vals[iteration][1], {onComplete: twn -> {
                PlayState.instance.runningTweens.remove(tweenName);
                }}));
            }
            
        }

        iteration++;
    }
}