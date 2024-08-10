package object;

class SillyThing extends BGSprite {
    public static var time:Float = 0;
    public static var total:Int = 0;

    public var sillyX:Float = 0;
    public var baseY:Float = 0;

    final stuffSCALE:Array<Float> = [0.9, 1.8, 0.7, 0.85, 1.25, 0.8, 0.2, 0.15, 1];
    final stuffTIME:Array<Float> = [-1, 0.5, 0.3, -1.2, 1, 1.1, -1, 2, 1.2];

	public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false) {
        super(image, x, y, scrollX, scrollY, animArray, loop);
        this.ID = total;
        total++;
    }

    override public function draw() {
        this.y = baseY + (Math.sin(time*stuffTIME[ID])*(this.height*sillyX)*stuffSCALE[ID]);
        super.draw();
    }
}