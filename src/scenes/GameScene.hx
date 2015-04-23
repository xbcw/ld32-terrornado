package scenes;

import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.Entity;
import com.haxepunk.Sfx;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Data;
import Date;
import com.haxepunk.graphics.Text;
import flash.geom.Point;
import entities.Hero;
import Global;

class GameScene extends Scene
{
    public function new()
    {
        super();

        currentTime = Date.now().getTime();
        expireTime = Date.now().getTime() + 150 * 1000;
        expireText = DateTools.format( Date.fromTime(expireTime), "%l:%M%p");
        currentScore = 0;

        var backdrop:Backdrop = new Backdrop("graphics/testbackground.png",true,false);
        backdrop.scrollX = 1;
        var e:Entity = new Entity();
        e.graphic = backdrop;
        e.layer = 9999;
        add(e);
        camera = new Point();
        camera.x = 0;
        camera.y = 0;

        Data.load("highScoreData");
        highScore = Data.read("highScore", 0);

        Global.BACKGROUND_AUDIO.volume = 0.3;
        Global.BACKGROUND_AUDIO.loop();


        resetText = false;
        gameIsOver = false;
        worldScroll = 1;
        playClockTick = false;
        clockTickLastPlayed = Date.now().getSeconds();
    }

    public override function begin()
    {
        player = add(new entities.Hero(HXP.halfWidth, HXP.halfHeight));
        location = "town";
        locationSize = 1;
        locationName = Global.TOWN_NAMES[HXP.rand(Global.TOWN_NAMES.length)];
        maxSpawnTimer = 3;
        spawnCounter = 0;
        handleSpawn();
        populate();

        tickerBackground.graphic = Image.createRect(HXP.screen.width, 30, 0xFFFFFF);
        tickerBackground.x = 0;
        tickerBackground.y = HXP.screen.height - 30;
        tickerBackground.layer = 0;
        add(tickerBackground);

        newTickerText = 'The National Weather Service has issued a Tornado Warning effective until $expireText.'; 
        ticker = new Text(newTickerText);
        ticker.color = 0x000000;
        ticker.size = 28;
        ticker.x = HXP.screen.width + HXP.world.camera.x;
        ticker.y = HXP.screen.height - 32;
        addGraphic(ticker);

        clockBackground.graphic = Image.createRect(150, 30, 0xFFFFFF);
        clockBackground.x = 150;
        clockBackground.y = 32;
        clockBackground.layer = 0;
        add(clockBackground);

        clock = new Text(DateTools.format( Date.fromTime(currentTime), "%l:%M:%S"));
        clock.color = 0x000000;
        clock.size = 28;
        clock.x = 0;
        clock.y = 32;
        addGraphic(clock);

        scoreBackground.graphic = Image.createRect(150, 30, 0xFFFFFF);
        scoreBackground.x = HXP.world.camera.x + 150;
        scoreBackground.y = 30;
        scoreBackground.layer = 0;
        add(scoreBackground);

        score = new Text("$" + currentScore);
        score.color = 0x000000;
        score.size = 28;
        score.x = HXP.world.camera.x;
        score.y = 32;
        addGraphic(score);

        announcement = new Text("");
        announcement.color = 0x000000;
        announcement.size = 48;
        announcement.x = HXP.world.camera.x + HXP.width/3;
        announcement.y = HXP.height/5;
        addGraphic(announcement);

        map = new Spritemap("graphics/map.png", 128, 128);
        map.x = 145;
        map.y = 80;
        addGraphic(map);

        mapBorder.graphic = Image.createRect(130,130,0x000000);
        mapBorder.x = map.x - 1;
        mapBorder.y = map.y - 1;
        mapBorder.layer = 1;
        add(mapBorder);

        mapText = new Text(locationName);
        mapText.color = 0x000000;
        mapText.size = 14;
        mapText.x = map.x + 15;
        mapText.y = map.y + 5;
        addGraphic(mapText);
    }

    public override function update()
    {
        if(Input.released(Key.SPACE) && gameIsOver)
        {
            restartGame();
        }

        updateTicker();
        updateScore();
        updateClock();
        if(playClockTick && clockTickLastPlayed != Date.now().getSeconds())
        {
            Global.SFX_WHOOSH.volume = 0.3;
            Global.SFX_WHOOSH.play();
            clockTickLastPlayed = Date.now().getSeconds();
        }
        updateAnnouncement();
        updateMap();
        handleLocation();
        handleSpawn();

        HXP.world.camera.x += worldScroll;
        distanceCounter += worldScroll;
        super.update();
    }

    private function handleLocation()
    {
        if(HXP.world.camera.x > locationSize)
        {
            var r = HXP.rand(2);
            switch(r)
            {
                case 0:
                    location = "countryside";
                    locationSize = HXP.world.camera.x + HXP.width * (HXP.rand(3)+1);
                    locationName = Global.COUNTY_NAMES[HXP.rand(Global.TOWN_NAMES.length)] + " County";
                    Global.BACKGROUND_SIREN.stop();
                case 1:
                    location = "town";
                    locationSize = HXP.world.camera.x + HXP.width * (HXP.rand(3)+1);
                    locationName = Global.TOWN_NAMES[HXP.rand(Global.TOWN_NAMES.length)];
                    Global.BACKGROUND_SIREN.stop();
                    Global.BACKGROUND_SIREN.volume = 0.3;
                    Global.BACKGROUND_SIREN.loop();
                default:
                    location = "countryside";
                    locationSize = 1;
                    locationName = Global.COUNTY_NAMES[HXP.rand(Global.TOWN_NAMES.length)] + " County";
                    Global.BACKGROUND_SIREN.stop();
            }
            mapText.text = locationName;
            map.randFrame();
        }
    }

    private function handleSpawn()
    {
        spawnTimer -= HXP.elapsed;
        if (spawnTimer < 0 && !gameIsOver)
        {
            switch(location)
            {
                case "countryside":
                    spawnCountrySide();
                case "town":
                    spawnTown();
                default:
                    spawnCountrySide();
            }
            spawnCounter++;
            spawnTimer = maxSpawnTimer; // every second
        }
    }

    private function spawnTown()
    {
        if(distanceCounter >= 128)
        {
            if(HXP.rand(6) > 0)
            {
                if(HXP.rand(9) > 0)
                {
                    add(new entities.Building(HXP.world.camera.x + HXP.width, 100));
                } 
                if(HXP.rand(9) > 0)
                {
                    add(new entities.Building(HXP.world.camera.x + HXP.width, 250));
                }
                if(HXP.rand(9) > 0)
                {
                    add(new entities.Building(HXP.world.camera.x + HXP.width, 520));
                }
            }
            distanceCounter = 0;
            spawnCarsAndPeople();
        } 
    }

    private function spawnCarsAndPeople()
    {
        randY = Math.random() * HXP.height + 25;
        var randSpawn = HXP.rand(9);
        if(randSpawn == 0)
        {
            add(new entities.Enemy(HXP.world.camera.x + HXP.width, randY, -HXP.rand(2)-1,"person"));
        }
        else if(randSpawn == 1)
        {
            add(new entities.Enemy(HXP.world.camera.x, randY, 2,"person"));
        }
        randSpawn = HXP.rand(9);
        if(randSpawn == 0)
        {
            add(new entities.Enemy(HXP.world.camera.x + HXP.width, 400+HXP.rand(70), -HXP.rand(2)-1,"car"));
        }
        else if(randSpawn == 1)
        {
            add(new entities.Enemy(HXP.world.camera.x, 400+HXP.rand(70), 3,"car"));
        }
    }


    private function spawnCountrySide()
    {
        randY = Math.random() * HXP.height + 25;
        spawnCarsAndPeople();
        if(randY > 525 || randY < 250)
        {
            add(new entities.Building(HXP.world.camera.x + HXP.width, randY));
        }
        distanceCounter = 0;
    }

    private function updateAnnouncement()
    {
        announcement.x = HXP.world.camera.x + HXP.width/3;
        if(announcementTimer > 0)
        {
            announcementTimer--;
            if(announcementTimer == 0)
            {
                announcement.text = '';
            }
        }
    }

    private function updateClock()
    {
        clock.x = HXP.world.camera.x + HXP.screen.width - 132;
        clockBackground.x = HXP.world.camera.x + HXP.screen.width - 132;
        currentTime = Date.now().getTime();
        clock.text = DateTools.format(Date.fromTime(currentTime), "%l:%M:%S");
        if(currentTime >= expireTime && !gameIsOver)
        {
            gameOver();
        }
        else if (expireTime - currentTime < 15 * 1000 && !gameIsOver)
        {
            clock.color = 0xFF0000;
            playClockTick = true;
        } else
        {
            clock.color = 0x000000;
            playClockTick = false;
        }
    }

    private function updateMap()
    {
        map.x = HXP.world.camera.x + HXP.screen.width - 150;
        mapBorder.x = map.x - 1;
        mapText.x = map.x + 15;
    }

    private function updateScore()
    {
        score.x = HXP.world.camera.x+150;
        scoreBackground.x = HXP.world.camera.x+150;
        score.text = "$" + currentScore;
    }

    private function updateTicker()
    {
        expireText = DateTools.format( Date.fromTime(expireTime), "%l:%M%p");
        ticker.x -= 1;
        tickerBackground.x = HXP.world.camera.x;
        if(ticker.x <= -HXP.screen.width + HXP.world.camera.x || resetText)
        {
            ticker.x = HXP.screen.width + HXP.world.camera.x;
            ticker.text = newTickerText;
            resetText = false;
        }
    }

    public function updateTickerText(text:String)
    {
        switch(text)
        {
            case "expire":
                switch(HXP.rand(3))
                {
                    case 0:
                        newTickerText = 'The National Weather Service has issued a Tornado Warning for $locationName effective until $expireText.'; 
                    case 1:
                        newTickerText = 'The tornado warning for $locationName has been extended until $expireText.'; 
                    case 2:
                        newTickerText = 'A Tornado Warning has been issued for $locationName effective until $expireText.'; 
                    case 3:
                        newTickerText = 'A storm capable of producing large hail, heavy rainfall, and damaging winds will be in $locationName until $expireText.'; 
                    default:
                        newTickerText = 'The National Weather Service has issued a Tornado Warning for $locationName effective until $expireText.'; 
                }
            default:
                newTickerText = 'missingNo';
        }
    }

    private function gameOver()
    {
        remove(player);
        worldScroll = 0;
        gameIsOver = true;
        resetText = true;
        playClockTick = false;
        newTickerText = 'The National Weather Service has lifted the Tornado Warning for $locationName.  All reports say sunny skies ahead.';
        gameOverSprite = new Spritemap("graphics/rainbow.png", HXP.width, HXP.height);
        gameOverSprite.x = HXP.world.camera.x;
        addGraphic(gameOverSprite);

        gameOverText = new Text("The Tornado Warning has expired.\nYou caused $" + currentScore + " in damages.");
        gameOverText.color = 0x000000;
        gameOverText.size = 42;
        gameOverText.x = HXP.world.camera.x + HXP.width/4;
        gameOverText.y = HXP.height/4;
        addGraphic(gameOverText);

        continueText = new Text("Press 'SPACEBAR' to restart");
        continueText.color = 0x000000;
        continueText.size = 42;
        continueText.x = HXP.world.camera.x + HXP.width/4;
        continueText.y = HXP.height-100;
        addGraphic(continueText);

        highScoreText = new Text('High Score: $' + highScore);
        highScoreText.color = 0x000000;
        highScoreText.size = 42;
        highScoreText.x = HXP.world.camera.x + HXP.width/4;
        highScoreText.y = HXP.height-200;
        addGraphic(highScoreText);

        if(currentScore > highScore)
        {
            highScore = currentScore;
            Data.write("highScore", highScore);
            Data.save("highScoreData");
        }

        Global.BACKGROUND_SIREN.stop();
        Global.BACKGROUND_AUDIO.stop();
    }

    private function restartGame()
    {
        HXP.world.removeAll;
        HXP.scene = new scenes.GameScene();
    }

    private function populate()
    {
        for (i in 0...HXP.rand(10))
        {
            var r = HXP.rand(HXP.height);
            if(r > 525 || r < 250)
            {
                add(new entities.Building(HXP.rand(HXP.width), r));
            }
        }
    }

    private var spawnTimer:Float = 0;
    private var maxSpawnTimer:Float = 2;
    private var spawnCounter:Int = 0;
    private var distanceCounter:Float = 0;

    private var gameIsOver:Bool = false;
    private var resetText:Bool = false;
    private var gameOverSprite:Spritemap;
    private var gameOverText:Text;
    private var continueText:Text;
    private var highScoreText:Text;

    private var ticker:Text;
    private var tickerBackground:Entity = new Entity();
    private var clock:Text;
    private var clockBackground:Entity = new Entity();
    private var score:Text;
    private var scoreBackground:Entity = new Entity();

    private var currentTime:Float;

    private var location:String = "countryside";
    private var locationSize:Float = 1;
    private var locationName:String = "locationName";

    public var announcement:Text;
    public var announcementTimer:Int = 0;

    private var map:Spritemap = new Spritemap("graphics/map.png", 128, 128);
    private var mapBorder:Entity = new Entity();
    private var mapText:Text;

    private var randY:Float = 0;
    private var playClockTick:Bool = false;
    private var clockTickLastPlayed:Int = 0;

    public var highScore:Int;
    public var currentScore:Int; 
    public var player:Hero;
    public var expireTime:Float;
    public var expireText:String;
    public var worldScroll:Float = 0;
    public var newTickerText:String = '';
}
