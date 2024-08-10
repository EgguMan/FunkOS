package object.note;

import backend.chart.Conductor;
import states.PlayState;
import flixel.FlxSprite;
using StringTools;

class HoldNoteSplash extends FlxSprite {
	private var colArray:Array<String> = ['Purple', 'Blue', 'Green', 'Red']; // colors
    var col:String = '';

    public var animState:String = 'none';
    public var playing:Bool = false;
    
    var readyToPlay:Bool = false;
    
    var data:Int = 0;

    public var done:Bool = false;

    public var localUpdatedTime:Float = 0;

    override public function new(noteData:Int) {
        super();
        col = colArray[noteData];
        frames = backend.Paths.getSparrowAtlas('noteAssets/splash/scroll/${col.toLowerCase()}');
        animation.addByPrefix('start', 'holdCoverStart$col', 24, false);
        animation.addByPrefix('hold', 'holdCover$col', 24, false);
        animation.addByPrefix('end', 'holdCoverEnd$col', 24, false);
        animation.finishCallback = animDone; // i forgot the syntax while writing this lowkey
        animation.play('end');
        data = noteData;
        visible = false;
    }

    public function updated() {
        localUpdatedTime = 0; // final safeguared to make sure it doesnt live forever
    }

    override function update(f:Float) {
        localUpdatedTime+=f;
        super.update(f);
    }

    function animDone(name:String) {
        switch (name){
            case 'start': // when the start animation is done then do some funny
                readyToPlay = false;
                playing = true;
                visible = true;
                if (animState != 'hold') {
                    animation.play('end');
                } else {
                    animation.play('hold');
                }
            case 'hold':
                if ((PlayState.instance.holdNoteSplashes[data] != this && PlayState.instance.holdNoteSplashes[data] != null) || PlayState.instance.holdNoteSplashes[data] == null || localUpdatedTime > Conductor.crochet/4000) {
                    kill();
                }
                if (animState == 'hold' && PlayState.instance.holdNoteSplashes[data] != null) 
                    animation.play('hold');
                else {
                    PlayState.instance.holdNoteSplashes[data] = null;
                    animation.play('end');
                }
            case 'end':
                kill();
        }
    }

    override public function kill() {
        playing = false;
        visible = false;
        animState = 'none';
        PlayState.instance.grpSusSplash.remove(this);
        if (PlayState.instance.holdNoteSplashes[data] != null && PlayState.instance.holdNoteSplashes[data].ID == this.ID) {
            PlayState.instance.holdNoteSplashes[data] = null;
        }
        super.kill();
    }

    public function start() { // whar
        if (!visible) {
            animation.play('start');
            readyToPlay = true;
        }
    }
}