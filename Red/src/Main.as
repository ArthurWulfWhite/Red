package 
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ShaderFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;

	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Main extends Sprite 
	{
		[Embed(source = 'Scanlines.pbj', mimeType = 'application/octet-stream')]
		private var Scanlines : Class;
		private var SLShader : Shader = new Shader(new Scanlines());
		//states//
		private const START : uint = 0; //No one is chasing Red and the carrot is available//
		private const WOLF : uint = 1; //Only the wolf is chasing Red(carrot available)//
		private const BUNNY : uint = 2; //Only the bunny is chasing Red(carrot unavailable)//
		private const BOTH : uint = 3; //They are both chasing Red(carrot unavailable)//
		private const NONE : uint = 4; //No one is chasing red(carrot unavailable)//
		
		private const BASE_SPEED : Number = 7;
		
		private var gameState : uint = START;
		//Used to display messages to the player//
		//To be replaced if design is wanted//
		private var txt : TextField = new TextField();
		
		private var currentLevel : int = 0;
		private var num : int = 0;
		
		//The game level//
		private var surface : Shape = new Shape();
		private var forest : Forest = new Forest();
		
		//The stars of the game//
		private var red : Red = new Red();
		private var carrot : Carrot = new Carrot();
		private var bunny : Bunny = new Bunny();
		private var wolf : Wolf = new Wolf();
		private var grandma : Grandma = new Grandma();
		
		//texture
		private var grass : Grass = new Grass();
		
		//used to read lvl data//
		private var data : Array = new Array();
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point

			surface.cacheAsBitmap = true;
			addChild(surface);
			surface.filters = [new ShaderFilter(SLShader)];
			forest.cacheAsBitmap = true;
			addChild(forest);
			forest.filters = [new ShaderFilter(SLShader)];
			//setup txt
			txtSetup();
			//load XML data
			XMLLoader.init();
			//run game
			stage.addChild(this);
			drawShalav(0);
			addEventListener(Event.ENTER_FRAME, onEnterFrame)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		
		private function onKey(e: KeyboardEvent):void
		{
			trace(currentLevel);
			drawShalav(++num);
		}
		
		private function onEnterFrame(e : Event):void
		{
			//I always move red//
			//I always check if she reached grandmas house//
			if (wolf.hitTestObject(red)) gameOver("You were eaten by a wolf");
			if (red.hitTestObject(grandma)) drawShalav(++currentLevel);
			//red's movement//
			red.speedMultiplier = 0.05 + 
				Math.max(0, (stage.stageWidth / 2 - distance(red.x, red.y, mouseX, mouseY))) / (stage.stageWidth/2);
			var angle : Number = Math.atan2(mouseY - red.y, mouseX - red.x);
			var stepX : int = BASE_SPEED * red.speedMultiplier * Math.cos(angle);
			var stepY : int = BASE_SPEED * red.speedMultiplier * Math.sin(angle);
			var move : Boolean = true;
			while (Math.abs(stepX) + Math.abs(stepY) > 0 && move && distance(red.x, red.y, mouseX, mouseY) > 2)
			{
				move = false;
				if (stepX)
				{
					if (hitTestPoint(red.x + sign(stepX) * red.size, red.y, true))
					{
						red.x += sign(stepX) * Math.min(Math.abs(stepX), 1);
						move = true;
						stepX -= sign(stepX) * Math.min(Math.abs(stepX), 1);
					}
				}
				if (stepY)
				{
					if (hitTestPoint(red.x, red.y  + sign(stepY) * red.size, true))
					{
						red.y += sign(stepY) * Math.min(Math.abs(stepY), 1);
						move = true;
						stepY -= sign(stepY) * Math.min(Math.abs(stepY), 1);
					}
				}				
			}
			//affected by the distance from the pointer//
			//affected by the time she is moving
			switch(gameState)
			{
				case START:
					if (wolf.way >= 0.99) wolf.way = -0.99;
					wolf.way += 0.004;
					wolf.walk();
					if (wolf.sees(red)) gameState = WOLF;
					if (red.hitTestObject(carrot))
					{
						gameState = BUNNY;
						removeChild(carrot);
						//play ding sound
					}
				break;
				
				case WOLF:
					if (wolf.way >= 0.99) wolf.way = -0.99;
					wolf.way += 0.004;
					chase(wolf, red);
					if (wolf.hitTestObject(bunny))
					{
						gameState = NONE;
						//slowly remove..
						removeChild(bunny);
					}
					if (red.hitTestObject(carrot))
					{
						gameState = BOTH;
						removeChild(carrot);
						//play ding sound
					}
				break;
				
				case BUNNY:
					//+move red
					wolf.way += 0.004;
					wolf.walk();
					if (wolf.sees(red)) gameState = BOTH;
					chase(bunny, red);
					if (bunny.hitTestObject(red)) gameOver("You were bitten by a rabid bunny");
					//carrot is not being checked
				break;
				
				case BOTH:
					//+move red
					chase(wolf, red);
					chase(bunny, red);
					if (bunny.hitTestObject(red)) gameOver("You were bitten by a rabid bunny");
					if (wolf.hitTestObject(bunny))
					{
						gameState = NONE;
						//slowly remove..
						removeChild(bunny);
					}
					//carrot not available
				break;
				
				case NONE:
					//+move red
					//check if red is touching wolf// ?? always
				break;
				
			}
		}
		
		private function addDmuyot():void
		{
			placeDmut("red");
			placeDmut("bunny");
			placeDmut("carrot");
			placeDmut("grandma");
			createWolf();
		}
		
		private function createWolf ():void
		{
			placeDmut("wolf");
			wolf.path = String(XMLLoader.xml.shalav[currentLevel].path[0]).split(",");
			for (var i : int = 0; i < wolf.path.length; i++)
			{
				wolf.path[i] = Number(wolf.path[i]);
			}
			wolf.x = wolf.path[0];
			wolf.y = wolf.path[1];
			wolf.way = 0;
		}
		
		private function placeDmut(dName : String):void
		{
			data = String(XMLLoader.xml.shalav[currentLevel][dName]).split(",");
			var d : Dmut = Dmut(this[dName]);
			if(d.parent == null)addChild(d);
			d.x = Number(data[0]);
			d.y = Number(data[1]);
		}
		
		private function drawShalav(lvlNum : int):void
		{
			gameState = START;
			this.currentLevel = lvlNum;
			addDmuyot();
			surface.graphics.clear();
			surface.graphics.lineStyle(24, 0x8800);
			surface.graphics.lineBitmapStyle(grass);
			var i : int = 0;
			for each(var a : XML in XMLLoader.xml.shalav[currentLevel].area)
			{
				surface.graphics.beginFill(0x8404);
				surface.graphics.beginBitmapFill(grass);
				data = String(a).split(",");
				for (i = 0; i < data.length; i++)
				{
					data[i] = Number(data[i]);
				}
				surface.graphics.moveTo(data[0], data[1]);
				for (i = 0; i < data.length - 2; i += 2)
				{
					surface.graphics.curveTo
					(
						data[i], data[i + 1],
						(data[i] + data[i + 2]) / 2,
						(data[i+1] + data[i + 3])/2
					);
				}
				surface.graphics.endFill();
			}
			for each(var p : XML in XMLLoader.xml.shalav[currentLevel].path)
			{
				data = String(p).split(",");
				for (i = 0; i < data.length; i++)
				{
					data[i] = Number(data[i]);
				}
				surface.graphics.moveTo(data[0], data[1]);
				for (i = 0; i < data.length - 2; i += 2)
				{
					surface.graphics.curveTo
					(
						data[i], data[i + 1],
						(data[i] + data[i + 2]) / 2,
						(data[i+1] + data[i + 3])/2
					);
				}
				surface.graphics.lineTo(data[i], data[i + 1]);
			}
			forest.spawnForest(surface);
		}
		
		private function getSpeed(dmut : Dmut):Number
		{
			return dmut.speedMultiplier * BASE_SPEED;
		}
		
		private function chase(dmutA : Dmut, dmutB : Dmut):void//A is chasing B
		{
			var angle : Number = Math.atan2(dmutB.y - dmutA.y, dmutB.x - dmutA.x);
			dmutA.posX = dmutA.x + getSpeed(dmutA) * Math.cos(angle);
			dmutA.posY = dmutA.y + getSpeed(dmutA) * Math.sin(angle);
		}
		
				
		private function txtSetup():void
		{
			stage.addChild(txt);
			txt.selectable = false;
			txt.textColor = 0xffffff;
			txt.width = stage.stageWidth;
			txt.defaultTextFormat = new TextFormat(null, 22);//change this to aligh to center
		}
		
		//current gameover mechanics//
		
		private function gameOver(str : String):void
		{
			//stops the game, shows the end game message, waits for player response.
			gameState = NONE;
			txt.text = str;
			alpha = 0;
			setTimeout(function():void{
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onClick);},
			250);
		}
		
		private function onClick(e : MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.CLICK, onClick);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onClick);
			resetLevel();
		}
		
		private function resetLevel():void
		{
			//draws the level on the game object//
			txt.text = "";
			drawShalav(currentLevel);
			alpha = 1;
		}
		
		public static function distance(x0 : Number, y0 : Number, x1 : Number, y1 : Number):Number
		{
			return Math.sqrt(Math.pow((x0 - x1), 2) + Math.pow(y0 - y1, 2));
		}
		
		private function sign(val : int):int
		{
			if (!val) return 0;
			if (val > 0) return 1;
			else return -1;
		}
	}
	
}