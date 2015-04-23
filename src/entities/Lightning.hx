package entities;

import scenes.GameScene;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.HXP;

class Lightning extends Entity
{
    public function new(x:Float, y:Float, call:String)
    {
        super(x, y);

        if(call == "strike1")
        {
            sprite = new Spritemap("graphics/lightningstrike.png", 128, 720); 
            sprite.add("strike1", [HXP.rand(2), HXP.rand(2), HXP.rand(2), HXP.rand(1)], 16);
            hitBoxX = 128;
            hitBoxY = 720;
            moveable = false;
        }
        else
        {
            sprite = new Spritemap("graphics/lightning.png", 384, 128);
            sprite.add("strike2", [0,1,2,3,4,5], 8);
            sprite.add("strike3", [0,1,5], 8);
            sprite.add("strike4", [1,2,5], 8);
            sprite.add("strike5", [2,1,4,5], 8);
            hitBoxX = 386;
            hitBoxY = 128;
            moveable = true;
        }

        if(HXP.rand(2) == 1)
        {
            sprite.flipped = true;
        }

        sprite.play(call);
        graphic = sprite;
        setHitbox(hitBoxX, hitBoxY);
        type = "lightning";
    }

    public override function update()
    {
        lifespan--;
        if(lifespan <= 0)
        {
            scene.remove(this);
        }

        if(moveable)
        {
            moveBy(cast(scene, GameScene).player.xVelocity, cast(scene,GameScene).player.yVelocity);
        }

        super.update();
    }

    private var sprite:Spritemap;
    private var sprite2:Spritemap;
    private var graphiclist:Graphiclist;
    private var lifespan = HXP.rand(100);
    private var hitBoxX:Int = 0;
    private var hitBoxY:Int = 0;
    private var moveable:Bool = true;
}
