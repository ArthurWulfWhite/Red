package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import Game;
	
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	public class LvlMaker extends Sprite 
	{
		private var data : Vector.<Number> = new Vector.<Number>();
		private var fill : Boolean = false;
		
		private var game:Game;
		public function LvlMaker():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			game = new Game ();
			addChild ( game );
			//graphics.lineStyle(16,0xcc00);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		
		private function onClick(e : MouseEvent):void
		{
			if (data.length == 0)
			{
				graphics.moveTo(e.stageX, e.stageY);
			}
			else
			{
				graphics.lineTo(e.stageX, e.stageY);
			}
			data.push(e.stageX, e.stageY);
		}
		
		private function onKey(e : KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.T:
					trace(data);
				break;
				
				case Keyboard.D:
					data = new Vector.<Number>();
					fill = false;
					graphics.endFill();
				break;
				
				case Keyboard.F:
					fill = !fill;
					if (fill) graphics.beginFill(0x9900);
					else graphics.endFill();
				break;
				
				case Keyboard.R:
					data = new Vector.<Number>();
					graphics.clear();
					graphics.lineStyle(16,0xcc00);
				break;
			}			
		}
		
	}
	
}