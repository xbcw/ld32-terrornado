package entities;

import com.haxepunk.graphics.Emitter;
import com.haxepunk.utils.Ease;
import com.haxepunk.Entity;

class Hail extends Entity
{
    private var _emitter:Emitter;

    public function new()
    {
        super(x, y);
        _emitter = new Emitter("graphics/particle.png", 2, 2);
        _emitter.newType("storm", [0]);
        _emitter.setMotion("storm",       // name
                    0,              // angle
                    50,            // distance
                    1,              // duration
                    360,            // ? angle range
                    -40,            // ? distance range
                    1,              // ? Duration range
                    Ease.quadOut    // ? Easing 
                    );
        _emitter.setAlpha("storm", 20, 0.1);
        _emitter.setGravity("storm", 5, 1);
        graphic = _emitter;
        layer = -1;
    }

    public function storm(x:Float, y:Float)
    {
       // for (i in 0...5)
       // {
            _emitter.emit("storm", x, y);
       // }
    }


}
