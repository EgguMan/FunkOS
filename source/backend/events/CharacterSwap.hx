package backend.events;

import states.PlayState;
import object.Character;
import object.Boyfriend;

using StringTools;

class CharacterSwap {
    public static var boyfriendMap:Map<String, Boyfriend> = new Map();
	public static var dadMap:Map<String, Character> = new Map();
	public static var gfMap:Map<String, Character> = new Map();

    public static function reset() { // initialize the event, push the maps into an array so that they can be cleared when the song is exited
        EventsCore.localMaps.push(boyfriendMap);
        EventsCore.localMaps.push(dadMap);
        EventsCore.localMaps.push(gfMap);
    }

    public static function addCharacterToList(newCharacter:String, type:Int) {
        if (!EventsCore.classes.contains(CharacterSwap)) EventsCore.classes.push(CharacterSwap);
        switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					PlayState.instance.boyfriendGroup.add(newBoyfriend);
					PlayState.instance.startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					PlayState.instance.dadGroup.add(newDad);
					PlayState.instance.startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if(PlayState.instance.gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					PlayState.instance.gfGroup.add(newGf);
					PlayState.instance.startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
    }

    public static function swapChar(charType:Int, value1:String, value2:String) {
        switch(charType) {
            case 0:
                var boyfriend = PlayState.instance.boyfriend;
                if(boyfriend.curCharacter != value2) {
                    if(!boyfriendMap.exists(value2)) {
                        CharacterSwap.addCharacterToList(value2, charType);
                    }

                    var lastAlpha:Float = boyfriend.alpha;
                    boyfriend.alpha = 0.00001;
                    boyfriend = boyfriendMap.get(value2);
                    boyfriend.alpha = lastAlpha;
                    PlayState.instance.iconP1.changeIcon(boyfriend.healthIcon);
                    PlayState.instance.boyfriend = boyfriend;
                }

            case 1:
                var dad = PlayState.instance.dad;
                var gf = PlayState.instance.gf;
                if(dad.curCharacter != value2) {
                    if(!dadMap.exists(value2)) {
                        CharacterSwap.addCharacterToList(value2, charType);
                    }

                    var wasGf:Bool = dad.curCharacter.startsWith('gf');
                    var lastAlpha:Float = dad.alpha;
                    dad.alpha = 0.00001;
                    dad = dadMap.get(value2);
                    if(!dad.curCharacter.startsWith('gf')) {
                        if(wasGf && gf != null) {
                            gf.visible = true;
                        }
                    } else if(gf != null) {
                        gf.visible = false;
                    }
                    dad.alpha = lastAlpha;
                    PlayState.instance.iconP2.changeIcon(dad.healthIcon);
                    PlayState.instance.dad = dad;
                    PlayState.instance.gf = gf;
                }

            case 2:
                var gf = PlayState.instance.gf;
                if(gf != null)
                {
                    if(gf.curCharacter != value2)
                    {
                        if(!gfMap.exists(value2))
                        {
                            CharacterSwap.addCharacterToList(value2, charType);
                        }

                        var lastAlpha:Float = gf.alpha;
                        gf.alpha = 0.00001;
                        gf = gfMap.get(value2);
                        gf.alpha = lastAlpha;
                        PlayState.instance.gf = gf;
                    }
                }
        }
    }
}