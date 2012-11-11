package  
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Etherlord
	 */
	public class RedUtils 
	{
		/**
		 * Calculate x or y coordinate of a point on t% of a quadratic spline defined by x1,x2,x3 or y1,y2,y3
		 * @param	v1 first anchor coordinate (x when calculating output x and y otherwise)
		 * @param	v2 control point coordinate (x when calculating output x and y otherwise)
		 * @param	v3 second anchor coordinate (x when calculating output x and y otherwise)
		 * @param	t percentage of way between first and second anchor
		 */
		static public function quadPoint ( v1:Number, v2:Number, v3:Number, t:Number ):Number
		{
			var t2:Number = 1 - t;
			return t2 * t2 * v1 + 2 * t * t2 * v2 + t * t * v3;
		}
		
		/**
		 * taken from http://segfaultlabs.com/docs/quadratic-bezier-curve-length
		 */
		static public function quadLength ( x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number ):Number
		{
			var ax:Number = x1 - 2 * x2 + x3;
			var ay:Number = y1 - 2 * y2 + y3;
			
			var bx:Number = 2 * x2 - 2 * x1;
			var by:Number = 2 * y2 - 2 * y1;
			var A:Number = 4 * (ax * ax + ay * ay);
			var B:Number = 4 * (ax * bx + ay * by);
			var C:Number = bx * bx + by * by;
			var Sabc:Number = 2 * Math.sqrt ( A + B + C );
			var A_2:Number = Math.sqrt ( A );
			var A_32:Number = 2 * A * A_2;
			var C_2:Number = 2 * Math.sqrt ( C );
			var BA:Number = B / A_2;
			
			return ( A_32 * Sabc + A_2 * B * (Sabc - C_2) + (4 * C * A - B * B) * Math.log( (2 * A_2 + BA + Sabc) / (BA + C_2) ) ) / (4 * A_32);
		}
		
	}
}