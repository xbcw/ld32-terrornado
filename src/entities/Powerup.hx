package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import scenes.GameScene;

class Powerup extends Entity
{
    public function new(x:Float, y:Float, powerup:String)
    {
        super(x,y);

        this.powerup = powerup;

        sound = new Sfx("audio/powerup.wav");
        sprite = new Spritemap("graphics/powerups.png", 32,32);
        init();
        sprite.play(powerup);
        
        graphiclist = new Graphiclist([sprite]);
        graphic = graphiclist;
        setHitbox(32,32);
        layer = 100;
        activeTime = 0;
        infoTextMoveCounter = 0;
        destroyed = false;
    }

    private function init()
    {
        switch(powerup) 
        {
            case "lightning":
                sprite.add(powerup,[0]);
            case "storm":
                sprite.add(powerup,[1]);
            case "speedup":
                sprite.add(powerup,[2]);
            case "hailstorm":
                sprite.add(powerup,[3]);
            default:

        }
    }

    public override function update()
    {
        if(!destroyed)
        {
            if(activeTime <= 60)
            {
                activeTime ++;
            } else
            {
                var e:Entity = collide("player", x, y); 
                if(e != null && activeTime > 60)
                {
                    switch(powerup)
                    {
                        case "lightning":
                            if(cast(e, Hero).lightningPower + 25 < 250)
                            {
                                cast(e, Hero).lightningPower += 25;
                                effectText = "lightning";
                            }
                            else
                            {
                                cast(e, Hero).lightningPower = 250;
                                effectText = "max lightning";
                            }

                        case "storm":
                            cast(scene,GameScene).expireTime += 10 * 1000;
                            cast(scene,GameScene).updateTickerText("expire");

                            effectText = "10 seconds";
                        case "speedup":
                            cast(e,Hero).speed += 0.05;
                            effectText = "speed";
                        case "hailstorm":
                            scene.add(new entities.Hailstorm(HXP.world.camera.x+HXP.rand(HXP.width), HXP.rand(HXP.height), 1000));
                            scene.add(new entities.Hailstorm(HXP.world.camera.x+HXP.rand(HXP.width), HXP.rand(HXP.height), 1000));
                            scene.add(new entities.Hailstorm(HXP.world.camera.x+HXP.rand(HXP.width), HXP.rand(HXP.height), 1000));
                            effectText = "hailstorm";
                        default:
                            effectText = "missingNo";

                    }
                    sound.play();

                    infoText = new Text('+$effectText');
                    infoText.color = 0x000000;
                    infoText.size = 14;
                    infoText.x += 10;
                    infoText.y -= height/2;
                    graphiclist.remove(sprite);
                    graphiclist.add(infoText);

                    destroyed = true;
                    sprite.clear();
                }
            }

            if(this.x < HXP.world.camera.x)
            {
                scene.remove(this);
            }
        }
        else
        {
            if(infoText != null)
            {
                infoTextMoveCounter += 1;
                infoText.y -= 1;
                if(infoTextMoveCounter >= 50)
                {
                    scene.remove(this);
                }

            }
        }   

        super.update();
    }

    private var sprite:Spritemap;
    private var graphiclist:Graphiclist;
    private var sound:Sfx = new Sfx("audio/powerup.wav");
    private var powerup:String;
    private var activeTime:Int = 0;
    private var infoText:Text;
    private var effectText:String;
    private var infoTextMoveCounter:Int;
    private var destroyed = false;

}

