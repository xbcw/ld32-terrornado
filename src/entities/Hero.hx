package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import Std;
import entities.Building;
import com.haxepunk.graphics.Text;

class Hero extends Entity
{
    public function new(x:Float, y:Float)
    {
        super(x,y);

        heroSprite = new Spritemap("graphics/hero.png", 128, 128);
        heroSprite.add("walk", [1,2,3,4], 12);
        heroSprite.play("walk");

        graphic = heroSprite;
        setHitbox(128, 128);

        Input.define("up", [Key.UP, Key.W]);
        Input.define("down", [Key.DOWN, Key.S]);
        Input.define("left", [Key.LEFT, Key.A]);
        Input.define("right", [Key.RIGHT, Key.D]);

        xVelocity = 0;
        yVelocity = 0;
        type = "player";
        layer = cast(-y);
    }

    private function handleInput()
    {
        xAcceleration = 0;
        yAcceleration = 0;

        if (Input.check("up"))
        {
            yAcceleration = -1;
        }

        if (Input.check("down"))
        {
            yAcceleration = 1;
        }

        if (Input.check("right"))
        {
            xAcceleration = 1;
        }

        if (Input.check("left"))
        {
            xAcceleration = -1;
        }
    }

    private function move()
    {
        xVelocity += xAcceleration * speed;
        if (Math.abs(xVelocity) > maxXVelocity)
        {
            xVelocity = maxXVelocity * HXP.sign(xVelocity);
        }

        yVelocity += yAcceleration * speed;
        if (Math.abs(yVelocity) > maxYVelocity)
        {
            yVelocity = maxYVelocity * HXP.sign(yVelocity);
        }

        if (x + xVelocity > HXP.world.camera.x + HXP.width - this.width)
        {
            xVelocity = 0;
        }
        else if( x + xVelocity < HXP.world.camera.x && xVelocity < 1)
        {
            xVelocity = 1 + drag;
        }
/*
        if ((x < (HXP.world.camera.x + HXP.width / 3)) && !Input.check("left") && !Input.check("right"))
        {
            xVelocity = 1 + drag;
        }
*/
        if (y + yVelocity >= HXP.height - this.height || (y + yVelocity <= 0))
        {
            yVelocity = 0;
        }

        if (xVelocity < 0)
        {
            xVelocity = Math.min(xVelocity + drag, 0);
        }
        else if (xVelocity > 0)
        {
            xVelocity = Math.max(xVelocity - drag, 0);
        }

        if (yVelocity < 0)
        {
            yVelocity = Math.min(yVelocity + drag, 0);
        }
        else if (yVelocity > 0)
        {
            yVelocity = Math.max(yVelocity - drag, 0);
        }
    }

    private function handlePowerups()
    {
        if(powerupRandom <= lightningPower)
        {
            switch(HXP.rand(5))
            {
                case 0:
                    HXP.scene.add(new Lightning(HXP.rand(HXP.width) + HXP.world.camera.x, HXP.rand(HXP.height)-HXP.height, "strike1"));
                case 1:
                    HXP.scene.add(new Lightning(this.x - 128, this.y, "strike2"));
                case 2:
                    HXP.scene.add(new Lightning(this.x - 128, this.y, "strike3"));
                case 3:
                    HXP.scene.add(new Lightning(this.x - 128, this.y, "strike4"));
                case 4:
                    HXP.scene.add(new Lightning(this.x - 128, this.y, "strike5"));
                default:
                    scene.add(new Lightning(this.x - 128, this.y, "strike2"));
            }
            powerupRandom = HXP.rand(500);
        }
        if(time % 30 == 0)
        {
            powerupRandom = HXP.rand(500);
        }
    }

    public function getDamage():Int
    {
        return baseDamage;
    }

    private function handleTime()
    {
        time ++;
        if (time == 60)
        {
            time = 0;
        }
    }

    public override function update()
    {
        handleInput();
        handlePowerups();
        move();
        moveBy(xVelocity, yVelocity);
        handleTime();
        super.update();
    }

    public var xVelocity:Float;
    public var yVelocity:Float;
    private var xAcceleration:Float;
    private var yAcceleration:Float;

    private var heroSprite:Spritemap;
    private var lightningSprite:Spritemap;
    private var lightningImage:Image;

    private var graphiclist:Graphiclist;

    private static inline var maxXVelocity:Float = 8;
    private static inline var maxYVelocity:Float = 8;
    private static inline var drag:Float = 0.1;

    private var powerupRandom:Int = HXP.rand(500);
    private var charge:Int = 0;

    public var baseDamage = 50;
    private var time:Int = 0;
    private var hasLightning:Bool = false;
    
    public var lightningPower:Int = 0;
    public var speed:Float = 0.2;
}
