package backend.events;

import backend.chart.Conductor;
import flixel.tweens.FlxTween;
import states.PlayState;
import flixel.FlxSprite;
import flixel.util.typeLimit.OneOfTwo;
import flixel.addons.effects.FlxTrail;
using StringTools;

typedef Trail = {
    trailObject:FlxTrail,
    isSprite:Bool,
    targetChar:String,
    targetObj:FlxSprite,
    options:TrailOptions
}

typedef TrailEventComponent = {
    newTrail:Bool,
    trail:Trail,
    configs:CommandConfigs
}

typedef CommandConfigs = {
    operation:String,
    value:Array<Dynamic>,
    target:String
}

// you may be wondering, why so many typdefs? Better than dynamic arrays

typedef TrailOptions = {
    length:Int,
    delay:Int,
    alpha:Float,
    diff:Float
}


class TrailEvent {
    public static var trails:Array<TrailEventComponent> = [];
    public static var iteration:Int = 0;

    public static var charTrails:Array<Trail> = [null, null, null];

    public static function reset() {
        for (trail in trails) {
            if (trail.trail != null) trail.trail.trailObject.kill();
        }
        trails = [];
        iteration = 0;
    }

    //okay so i've made this very convoluted, but thats just life working with only 2 values

    //for value 1, you can either have it be a sprite or a string. if it is a string it will assume it is either a character, or a operation.
    //if its a character, it will add a trail behind the target's group, using options as the values for the trail. 
    // if its an operation it will instead use the target as a command, and use the options as the value for the command, eg remove, 0.5, bf (time to fade out)

    //example of removal

    //V1 = 'remove'
    //V2 = char, bf
    //removes BFs trail

    public static function queue(target:OneOfTwo<String, FlxSprite>, options:String) {
        if (!EventsCore.classes.contains(TrailEvent)) EventsCore.classes.push(TrailEvent);
        var mainTrail:TrailEventComponent = {newTrail:true, trail:null, configs:null};
        var trailObject:Trail = {trailObject:null, isSprite:false, targetChar:'', targetObj: null, options:null};
        if (Std.isOfType(target, String)) {
            
            switch (target) {
                case 'bf' | 'boyfriend' | 'bop fiend' | '0':
                    trailObject.targetObj = PlayState.instance.boyfriend;
                    trailObject.targetChar = 'bf';
                case 'dad' | 'opponent' | '1':
                    trailObject.targetObj = PlayState.instance.dad;
                    trailObject.targetChar = 'dad';
                case 'girlfriend' | 'gf' | '2':
                    trailObject.targetObj = PlayState.instance.gf;
                    trailObject.targetChar = 'gf';
                default:
                    mainTrail.configs = {operation:"", value: [0, 0], target: ''};
                    mainTrail.newTrail = false;
                    mainTrail.configs.operation = (""+target).toLowerCase(); // we love dealing with dastardly dynamic defficenies
                    var split = options.replace(' ', '').split(',');
                    var array:Array<Float> = [Math.max(0, trails.length-1)];
                    switch (split[1]) {
                        case 'char':
                            mainTrail.configs.target = split[3];
                    }

                    switch (split[2]) {
                        case 'time':
                            var val = Std.parseFloat(split[1]);
                            if (Math.isNaN(val)) {
                                val = Conductor.crochet/4;
                            }
                            array.push(val);
                        }
                    mainTrail.configs.value = array;
            }
        } else {
            trailObject.isSprite = true;
            trailObject.targetObj = target;
        }
        
       
        if (mainTrail.newTrail) { 
            var trailOptions:TrailOptions = handleTrailOptions(options);
            trailObject.options = trailOptions;
            var flxTrail = new FlxTrail(trailObject.targetObj, null, trailOptions.length, trailOptions.delay, trailOptions.alpha, trailOptions.diff);

            trailObject.trailObject = flxTrail;
            mainTrail.trail = trailObject;
        } 

        trails.push(mainTrail);
    }

    public static function nextTrail() {
        trace(iteration);
        trace(trails);
        var toCheck = getLastTrail();

        if (toCheck.newTrail) {
            addNewTrail(toCheck.trail);
        } else {
            var useTrail = charTrails[0];
            if (toCheck.configs.target == 'dad') {
                useTrail = charTrails[1];
            } else if (toCheck.configs.target == 'gf') {
                useTrail = charTrails[2];
            }
            switch (toCheck.configs.operation) {
                case 'destroy' | 'kill':
                    useTrail.trailObject.kill();
                    if (toCheck.configs.operation == 'destroy' || toCheck.configs.operation == 'destroy') {
                        useTrail.trailObject.destroy();
                    }
                case 'remove':
                    PlayState.instance.remove(useTrail.trailObject);
            }
        }
    }

    static function addNewTrail(trail:Trail) {
        trail.trailObject.cameras = trail.targetObj.cameras;
        if (trail.isSprite) {
            PlayState.instance.insert(PlayState.instance.members.indexOf(trail.targetObj), trail.trailObject);
        } else {
            switch (trail.targetChar) {
                case 'bf':
                    charTrails[0] = trail;
                    PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup), trail.trailObject);
                case 'dad':
                    charTrails[1]= trail;
                    PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.dadGroup), trail.trailObject);
                case 'gf':
                    charTrails[2]= trail;
                    PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.gfGroup), trail.trailObject);
            }
        }
        iteration++;
    }

    public static function removeTrail(trail:Trail) {
        var name = 'trail event remove $iteration';
        trace(iteration);
        trace(trail.trailObject);
        PlayState.instance.remove(trail.trailObject);
        trail.trailObject.visible = false;
        
    }

    static function handleTrailOptions(options:String) {
        var optionArray = options.replace(' ', '').split(',');
        var optionObject:TrailOptions = {length: 10, delay:3, alpha:0.4, diff:0.05};

        var val:Float = Std.parseInt(optionArray[0]);
        if (!Math.isNaN(val)) optionObject.length = Math.floor(val);
        
        val = Std.parseInt(optionArray[1]);
        if (!Math.isNaN(val)) optionObject.delay = Math.floor(val);

        val = Std.parseFloat(optionArray[2]);
        if (!Math.isNaN(val)) optionObject.alpha = val;

        val = Std.parseFloat(optionArray[3]);
        if (!Math.isNaN(val)) optionObject.diff = val;

        return optionObject;
        
    }

    static function getLastTrail() {
        var ret:TrailEventComponent = null;
        var thisI = iteration;
        while (ret.trail.trailObject != null && PlayState.instance.members.contains(ret.trail.trailObject) && thisI != -1) {
            ret = trails[thisI];
            thisI -= 1;
        }
        return ret;
    }
}

/*class OperationCenter {

    public static function manage() {

    }
}*/