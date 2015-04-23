package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.Sfx;
import com.haxepunk.HXP;
import scenes.GameScene;

class Enemy extends Entity
{
    public function new(x:Float, y:Float, xVelocity:Float, category:String, isFlipped:Bool=false)
    {
        super(x, y);

        switch(category)
        {
            case "person":
                sprite = new Spritemap("graphics/runningguy.png", 32, 32);
                sprite.add("move", [0,1,2,3], 6);
                sprite.add("dead", [HXP.rand(3)+4]);
                sprite.play("move");

                sprite2 = new Spritemap("graphics/baddeath.png", 32, 32);
                sprite2.add("shock", [0,1,0,1,0,1,0,1,0,1], 12, false);
                sprite2.add("dead", [1]);
                sprite2.add("freeze", [2,3], 6, false);
                sprite2.add("freezedead",[3]);
                sprite2.play("dead");

                this.category = category;
                this.xVelocity = xVelocity;
                setHitbox(32, 32);

            case "car":
                sprite = new Spritemap("graphics/cars.png", 64, 32);
                var r = HXP.rand(4);
                sprite.add("move", [r]);
                sprite.add("dead", [r]);
                sprite.play("move");

                sprite2 = new Spritemap("graphics/wheel.png", 64, 32);
                sprite2.add("move", [0,1,2,3], 6);
                sprite2.add("dead", [4,5], 6);
                sprite2.add("idle", [HXP.rand(3)]);
                sprite2.play("move");

                if(xVelocity == 0)
                {
                    sprite2.play("idle");
                }

                this.category = "car";
                this.xVelocity = xVelocity*2;
                value = 15000 + HXP.rand(20000)-10000;
                setHitbox(64, 32);

            default:
                // do something
        }

        if(xVelocity > 0 || isFlipped)
        {
            sprite.flipped = true;
            sprite2.flipped = true;
        }

        graphiclist = new Graphiclist([sprite,sprite2]);
        graphic = graphiclist;
        type = "enemy";
        layer = 101;
    }

    public override function update()
    {
        time ++;
        if(time >= 60)
        {
            time = 0;
        }
        if(activeTime <= 60)
        {
            activeTime++;
        }
        else if(collide("player", x, y) != null && (!destroyed || category == "car"))
        {
            yVelocity += -0.4;
            elevation += -yVelocity;
            if (time % 3 == 0)
            {
                sprite.flipped = !sprite.flipped;
            }
        } 
        else if(collide("lightning", x, y) != null && !destroyed)
        {
            xVelocity = yVelocity = 0;
            if(category != "person")
            {
                cast(scene,GameScene).currentScore += value;

                score = new Text("$" + value);
                score.color = 0x000000;
                score.size = 14;
                score.x += 10;
                score.y -= height/2;
                graphiclist.add(score);
            }
            destroyed = true;
            sprite2.play("shock");
            sprite.play("dead");
        }
        else if(collide("hailstorm", x, y) != null && !destroyed)
        {
            xVelocity = yVelocity = 0;
            if(category != "person")
            {
                cast(scene,GameScene).currentScore += value;

                score = new Text("$" + value);
                score.color = 0x000000;
                score.size = 14;
                score.x += 10;
                score.y -= height/2;
                graphiclist.add(score);
                sprite.play("dead");
                sprite2.play("dead");
            }
            else
            {
                sprite.randFrame();
                sprite2.play("freeze");
            }
            destroyed = true;
        }
        else if(elevation > 0 && (!destroyed || category == "car"))
        {
            yVelocity += 0.4;
            elevation += -yVelocity;
            if(elevation <= 0)
            {
                xVelocity = yVelocity = 0;
                if(category != "person" && !destroyed)
                {
                    cast(scene,GameScene).currentScore += value;

                    score = new Text("$" + value);
                    score.color = 0x000000;
                    score.size = 14;
                    score.x += 10;
                    score.y -= height/2;
                    graphiclist.add(score);
                    if(HXP.rand(8) == 0)
                    {
                        HXP.scene.add(new entities.Powerup(this.x + this.width/2, this.y + this.height/2, "lightning"));
                    }
                    destroyed = true;
                }
                if(category == "person")
                {
                    if(HXP.rand(8) == 0)
                    {
                        HXP.scene.add(new entities.Powerup(this.x + this.width/2, this.y + this.height/2, "storm"));
                    }
                }
                sprite.play("dead");
                sprite2.play("dead");
            }
        } else if(elevation > 0)
        {
            yVelocity += 0.4;
            elevation += -yVelocity;
        } else if(elevation < 0)
        {
            yVelocity = elevation = 0;
        }

        if(destroyed && score != null)
        {
            scoreMoveCounter += 1;
            score.y -= 1;
            if(scoreMoveCounter >= 50)
            {
                graphiclist.remove(score);
            }
        }
        moveBy(xVelocity, yVelocity);
        if(this.x < HXP.world.camera.x - 256)
        {
            scene.remove(this);
        }

        super.update();
    }
    private var graphiclist:Graphiclist;
    private var sprite:Spritemap;
    private var sprite2:Spritemap;

    private var xVelocity:Float = 0;
    private var yVelocity:Float = 0;
    private var weight = 0;
    private var value = 0;

    private var destroyed:Bool = false;
    private var elevation:Float = 0;
    private var category:String = "";
    private var score:Text;
    private var scoreMoveCounter:Int = 0;

    private var activeTime:Int = 0;
    private var time:Int = 0;
}
