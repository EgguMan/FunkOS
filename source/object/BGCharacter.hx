package object;

typedef BGCharVars = {
    //plainLook:Bool, //on faster BPMs, it looks better if they change the direction they look on their idle, on slower BPMs it looks better if they switch it between idles. true = look on idle - UPDATE nope the animation was playing after its supposed ot
    lookAtSinger:Bool, //will use 4 specially named anims to look at the singer

    cheerOnChain:Bool, // will cheer if you chain notes together
    cheerLimit:Int // when to cheer
}

class BGCharacter extends Character {
    public var mustHit(default, set):Bool = false;
    @:noCompletion public function set_mustHit(inp:Bool):Bool {
        if (inp != mustHit && !isCheering) {
            timeToLook = true;
            dance(); // sectionhit is after beathit, so, it seems this is the best way for it to play on the right beat and not the next one.
        }
        mustHit = inp;
        return mustHit;
    }
    public static var timeToLook:Bool = false;

    public var cheerCount(default, set):Int = 0;
    @:noCompletion public function set_cheerCount(inp:Int) {
        if (cheerCount == bgData.cheerLimit-1 && bgData.cheerOnChain) { // make it match up with da counter
            cheerCount = 0;
            cheer();
        } else {
            cheerCount = inp;
        }
        return cheerCount;
    }
    public var isCheering:Bool = false;

    override public function new(name:String) {
        super(0, 0, name, false);
        this.setPosition(this.positionArray[0], this.positionArray[1]);
    }

    public var data:BGCharVars = null;
    
    /*public function lookNewDirection() {
        var animName = 'plainLook_';

        if (mustHit) {
            animName += 'mustHit';
        } else {
            animName += 'notHit';
        }

        trace('ANIM +' + animName);

        playAnim(animName, true); // would use reverse IF easing didnt exist....
    }*/

    override public function dance() {
        var animName:String = 'idle_';

        if (bgData.lookAtSinger) {
            if (timeToLook) {
                animName = 'lookTo_';
                timeToLook = false;
            }
    
            if (mustHit) {
                animName += 'mustHit';
            } else {
                animName += 'notHit';
            }
        } else {
            animName = 'idle';
        }

        playAnim(animName);
    }
    
    public function cheer() {
        isCheering = true;
        playAnim('cheer');
        animation.finishCallback = (thingy:String) -> {
            if (thingy == 'cheer') {
                isCheering = false;
            }
        }
    }
}