package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Arthur Wulf
	 */
	
	public class test extends Sprite
	{
		//data test//
		private var output : String = new String();
		private const size : uint = 100;
		private var val : int = 0;
		
		private var time : uint = 0;
		private var array : Array = new Array(size * size);
		private var array2d : Array = new Array(size);
		
		private var vector : Vector.<int> = new Vector.<int>(size * size, true);
		private var vector2d : Vector.<Vector.<int>> = new Vector.<Vector.<int>>(size, true);
		
		private var bitmap : BitmapData = new BitmapData(size, size);
		private var shape : Shape = new Shape();
		
		private var bitArray : ByteArray = new ByteArray();
		public function test() 
		{
			shape.cacheAsBitmap = true;
			addChild(shape);
			//new test method(no function call)//
			for (var k : int = 0; k <= 7; k++)
			{
				for (var i : int = 0; i < size; i++)
				{
					for(var j : int = 0; j < size; j++)
					{
						switch(k)
						{
							case 0:
							break;
							case 1:
								array[j + i * size] = j + i * size;
							break;
							case 2:
								if (j == 0) array2d[i] = new Array();
								array2d[i][j] = j + i * size;			
							break
							case 3:
								vector[j + i * size] = j + i * size;
							break
							case 4:
								if (j == 0) vector2d[i] = new Vector.<int>(size, true);
								vector2d[i][j] = (j + i * size);
							break
							case 5:
								bitmap.setPixel(j, i, j + i * size);
							break
							case 6:
								shape.graphics.lineStyle(1, 0x10 * (j + i * size));
								shape.graphics.drawRect(j, i, 1, 1);
							break
							case 7:
								bitArray.writeBoolean(true);
							break
						}
					}
				}
				outputTimer("Test" + k + " complete! ");
			}
			
			bitArray.position = 0;
			
			for (k = 0; k <= 7; k++)
			{
				val = 0;
				for (i = 0; i < size; i++)
				{
					for(j = 0; j < size; j++)
					{
						switch(k)
						{
							case 0:
							break;
							case 1:
								val = array[i + j * size];
							break;
							case 2:
								val = array2d[i][j];		
							break
							case 3:
								val = vector[j + i * size];
							break
							case 4:
								val = vector2d[j][j];
							break
							case 5:
								val = bitmap.getPixel(j, i);
							break
							case 6:
								if (shape.hitTestPoint(j, i, true)) val++; //do nothing
							break
							case 7:
								bitArray.readBoolean();
							break
						}
					}
				}
				
				outputTimer("Test" + k + " complete! ");
				trace(val);
			}
			/*
			outputTimer("Starting tests now");
			
			runTest(doNothing);
			outputTimer("Do nothing");
			
			runTest(writeArray);
			outputTimer("Array");
			
			runTest(writeArray2d);
			outputTimer("array2d");
			
			runTest(writeVector);
			outputTimer("Vector");
			
			runTest(writeVector2d);
			outputTimer("Vector2d");
			
			runTest(writeShape);
			outputTimer("Shape");
			
			runTest(writeBMPData);
			outputTimer("BMP");
			
			//read tests
			runTest(doNothing);
			outputTimer("read tests(do nothing)");
			
			runTest(readArray);
			outputTimer("Array");
			
			runTest(readArray2d);
			outputTimer("array2d");
			
			runTest(readVector);
			outputTimer("Vector");
			
			runTest(readVector2d);
			outputTimer("Vector2d");
			
			runTest(readShape);
			outputTimer("Shape");
			
			runTest(readBMPData);
			outputTimer("BMP");
			*/
			trace(output);

			shape.alpha = 0.5;
			addChild(new Bitmap(bitmap));
		}
		private function doNothing(x : uint, y : uint):void
		{
			//do nothing//
		}
		
		//read tests//
		private function readArray(x : uint, y : uint):void
		{
			val = array[x + y * size];
		}
		
		private function readArray2d(x : uint, y : uint):void
		{
			val = array2d[y][x];
		}

		private function readVector(x : uint, y : uint):void
		{
			val = vector[x + y * size];
		}
		
		private function readVector2d(x : uint, y : uint):void
		{
			val = vector2d[x][y];
		}
		
		private function readBMPData(x : uint, y : uint):void
		{
			val = bitmap.getPixel(x, y);
		}
		
		private function readShape(x : uint, y : uint):void
		{
			shape.hitTestPoint(x, y, true);
		}
		
		//write tests//
		private function writeArray(x : uint, y : uint):void
		{
			array[x + y * size] = x + y * size;
		}
		
		private function writeArray2d(x : uint, y : uint):void
		{
			if (x == 0) array2d[y] = new Array();
			array2d[y][x] = x + y * size;
		}
		
		private function writeVector(x : uint, y : uint):void
		{
			vector[x + y * size] = x + y * size;
		}
		
		private function writeVector2d(x : uint, y : uint):void
		{
			if (x == 0) vector2d[y] = new Vector.<int>(size, true);
			vector2d[y][x] = (x + y * size);
		}
		
		private function writeBMPData(x : uint, y : uint):void
		{
			bitmap.setPixel(x, y,0xff - (x + y * size));
		}
		
		private function writeShape(x : uint, y : uint):void
		{
			if((x + y * size)%4 == 0){
			shape.graphics.lineStyle(1, x + y * size);
			shape.graphics.drawRect(x, y, 1, 1);
			}
		}
		
		private function outputTimer(msg : String):void
		{
			output+= (msg + " test : " + String((getTimer() - time)) + "\n");
			time = getTimer();
		}
		
		private function runTest(f : Function):void //the function should be able to use two integers (i, j)
		{
			for (var i: int = 0; i < size; i++)
			{
				for (var j : int = 0; j < size; j++)
				{
					f(j, i);
				}
			}
		}
	}

}