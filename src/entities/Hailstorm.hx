package entities;

import scenes.GameScene;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.HXP;

class Hailstorm extends Entity
{
    public function new(x:Float, y:Float, lifespan:Int = 0)
    {
        super(x, y);

        sprite = new Spritemap("graphics/hailstorm.png", 768, 256); 
        sprite.add("storm", [0,1], 6);
//        sprite.scaleX = 3;
//        sprite.scaleY = 3;
        setHitbox(768,256);

        damage = 50;

        sprite.play("storm");
        graphic = sprite;
        type = "hailstorm";
        this.lifespan = lifespan;
    }

    public override function update()
    {
        lifespan--;
        if(lifespan <= 0)
        {
            scene.remove(this);
        }
//        moveBy(cast(scene, GameScene).player.xVelocity, cast(scene,GameScene).player.yVelocity);
//        this.x = HXP.world.camera.x;

        super.update();
    }

    private var sprite:Spritemap;
    private var lifespan:Int;
    public var damage:Int = 0;
}
