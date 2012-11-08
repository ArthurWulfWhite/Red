package redhood
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
	
	import flash.utils.getTimer;
	
	import flash.display.StageQuality;
	
	import redhood.Game;

	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class Main extends Sprite 
	{
		[Embed(source = '../Scanlines.pbj', mimeType = 'application/octet-stream')]
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
		private var forest : Forest = new Forest();
				
		private var game:Game;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.frameRate = 60;
			stage.quality = StageQuality.BEST;
			XMLLoader.init();
			
			game = new Game ();
			addChild ( game );
			game.init ();
			game.loadLevel ( 0 );
			
			/*
			surface.cacheAsBitmap = true;
			addChild(surface);
			surface.filters = [new ShaderFilter(SLShader)];
			forest.cacheAsBitmap = true;
			addChild(forest);
			forest.filters = [new ShaderFilter(SLShader)];
			*/
			//setup txt
			
			//txtSetup();
			
			//run game
			//stage.addChild(this);
			//drawShalav(0);
			//addEventListener(Event.ENTER_FRAME, onEnterFrame)
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			addChild ( new DebugSmoothness() );
		}
		
		/*
		private function onKey(e: KeyboardEvent):void
		{
			trace(currentLevel);
			drawShalav(++num);
		}
		
		private function onEnterFrame(e : Event):void
		{
			
		}
		
		private function addDmuyot():void
		{
			
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
		*/
		
	}
}