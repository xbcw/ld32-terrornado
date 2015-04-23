package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import scenes.GameScene;

class Building extends Entity
{
    public function new(x:Float, y:Float)
    {
        super(x,y);

        crash = new Sfx("audio/crash.wav");

        type = "building";
        sprite = new Spritemap("graphics/house.png", 128, 128);
        sprite.add("stand", [0]);
        sprite.add("falldown", [0,1,2,3], 3, false);
        sprite.add("fallen", [3]);
        sprite.play("stand");

        graphiclist = new Graphiclist([sprite]);
        graphic = graphiclist;

        if(HXP.rand(2) == 0)
        {
            sprite.flipped = true;
        }

        if(HXP.rand(9) == 0)
        {
            HXP.scene.add(new entities.Enemy(x+110, y+100, 0, "car", true));
        }

        setHitbox(128,128);
        destroyed = false;
        layer = 100;
        health = 5000 + HXP.rand(5000)-2500;
        value = 50000 + HXP.rand(20000)-10000;
    }

    public override function update()
    {
        e = collide("player", x, y); 
        if(e != null && !destroyed)
        {
            if(shake)
            {
                moveBy(0, 2);
                shake = false;
            }
            else
            {
                moveBy(0, -2);
                shake = true;
            }   
            health -= cast(e, Hero).getDamage();
        }

        e = collide("lightning", x, y); 
        if(e != null && !destroyed)
        {
            if(shake)
            {
                moveBy(0, 2);
                shake = false;
            }
            else
            {
                moveBy(0, -2);
                shake = true;
            }   
            health -= cast(scene, GameScene).player.lightningPower;
        }

        e = collide("hailstorm", x, y); 
        if(e != null && !destroyed)
        {
            if(shake)
            {
                moveBy(0, 2);
                shake = false;
            }
            else
            {
                moveBy(0, -2);
                shake = true;
            }   
            health -= cast(e, Hailstorm).damage;
        }

        if(health <= 0 && !destroyed)
        {
            destroyed = true;

            crash.play();

            sprite.play("falldown");
            cast(scene, GameScene).currentScore += value;

            score = new Text("$" + value);
            score.color = 0x000000;
            score.size = 16;
            score.x += 20;
            graphiclist.add(score);

            if(HXP.rand(5) == 0)
            {
                for (i in 0...HXP.rand(4))
                {
                    var r = HXP.rand(9);
                    if(r <= 4)
                    {
                        HXP.scene.add(new entities.Enemy(this.x+(r*5), this.y + (r*5), -1, "person"));
                    } 
                    else
                    {
                        HXP.scene.add(new entities.Enemy(this.x+(r*5), this.y + (r*5), 1, "person", true));
                    }   
                }
            }
            var r = HXP.rand(99);
            if(r <= 20 && r > 15)
            {
                HXP.scene.add(new entities.Powerup(this.x + this.width/2, this.y + this.height/2, "lightning"));
            }
            else if ( r > 10  && r <= 15)
            {
                HXP.scene.add(new entities.Powerup(this.x + this.width/2, this.y + this.height/2, "storm"));
            }
            else if (r > 5 && r <= 10)
            {
                HXP.scene.add(new entities.Powerup(this.x + this.width/2, this.y + this.height/2, "speedup"));
            }
            else if (r > 0 && r <= 5)
            {
                HXP.scene.add(new entities.Powerup(this.x + this.width/2, this.y + this.height/2, "hailstorm"));
            }
        }

        if(this.x < HXP.world.camera.x)
        {
            scene.remove(this);
        }
        
        if(destroyed)
        {
            scoreMoveCounter += 1;
            score.y -= 1;
            if(scoreMoveCounter >= 50)
            {
                graphiclist.remove(score);
            }
        }

        super.update();
    }

    private var sprite:Spritemap;
    private var graphiclist:Graphiclist;
    private var e:Entity;
    private var value:Int = 0;
    private var score:Text;
    private var scoreMoveCounter:Int = 0;

    public var health:Int = 500;
    public var destroyed:Bool;
    public var shake:Bool = false;

    private var crash:Sfx = new Sfx("audio/crash.wav");
}
