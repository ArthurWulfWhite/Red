package com.troyworks.data.skiplist.simple {
/*
* Skip lists offer good performance for both random
* and sorted input without the need to do any kind of reorganization.
* This relatively new structure first came to light in the 1989 work
*  of Bill Pugh from Department of Computer Science at the University of Maryland.
* In his original paper, which is freely available at ftp://ftp.cs.umd.edu/pub/skipLists/,
*  Pugh provides details into the mathematical background.
*
* This is a port of the java version here
* http://www.ftponline.com/Archives/premier/mgznarch/javapro/1998/jp_aprmay_98/tw0498/tw0498.asp#applet
*
* author: Troy Gardner 9/7/2004 www.troyworks.com
*
* Example Usage:
* //The following statement constructs a new empty skip list with a probability for higher node levels of 0.5 and a maximum level of 6:

var aList:SkipList = new SkipList(0.5, 6);
*
*
*
* ///////////traverse over the list
// init "cursor" element to header:
var cursor:SkipListElement = aSkipList.myHeader;
// find element in list:
var nextElement:SkipListElement = SkipListElement(cursor.forward[0]);
while (nextElement.key<SkipList.NIL_KEY) {
		trace(nextElement.value);
		cursor = nextElement;
		nextElement = SkipListElement(cursor.forward[0]);

}
*/
public class SkipList
{
protected var myMaxLevel:int;
protected var myLevel:int;
public var myHeader:SkipListElement;
protected var myProbability:Number;
//finalInteger.MAX_VALUE;int
public static var NIL_KEY:Number = Number.MAX_VALUE;

//////////////////////////////////////////////////////////////////
// Initialization Section
//////////////////////////////////////////////////////////////////
public function SkipList(){
	//route based on number of arguments
	if(arguments.length == 1){
			this.initWithNumberOfNodes.apply(this, arguments);
	}else if (arguments.length == 2){
			this.initWithProbability.apply(this, arguments);
	}
}

public function initWithProbability( fProbability:Number, intMaxLevel:int):void
{
	this.myProbability = fProbability;
	this.myMaxLevel = intMaxLevel;
	this.myLevel = 0;  // level of empty list

	// generate the header of the list:
	myHeader = new SkipListElement(0, null);
	myHeader.forward = new Vector.<SkipListElement>(myMaxLevel+1, true); //TODO: +1 needed?

	// append "NIL" element to header:
	var nilElement:SkipListElement = new SkipListElement( NIL_KEY, null );
	//nilElement.forward = new Vector.<SkipListElement>(myMaxLevel+1, true); //TODO: +1 needed?
	
	for (var i:int=0; i<=myMaxLevel; i++) {
		this.myHeader.forward[i] = nilElement;
	}
}

// 0.25 is a good probability
public static const GOOD_PROB:Number = 0.25;

public function initWithNumberOfNodes(lngMaxNodes:Number):void {
	//trace("init with number of nodes");
	// see Pugh for math. background
	this.initWithProbability(GOOD_PROB, Math.round(Math.ceil( Math.log(lngMaxNodes)/ Math.log(1/SkipList.GOOD_PROB))-1));
}

//////////////////////////////////////////////////////////////////////////////////////
//  Searching for an Element
//
//  Searching begins by setting the examined object,
//  which I call cursor, to the header. We traverse the list beginning at the highest
//  possible level of the header (see Figure 2); from there we proceed to the right
//  until we find an element whose successor's key is larger than the one we are looking for.
// Having found this element, we descend one level and continue the traversal in the same manner.
// When the traversal finally stops at level 0, it stops exactly one element before
// the node with higher key than searched for. It may be list's tail with Number.MAX_VALUE key.

// Since the list has a terminating NIL object whose key is greater than any key we might be searching for,
// traversal will always stop before the end of the list.
//This way we can omit time-consuming checks for null pointers when accessing forward pointers.

/**
 * returns SkipListElement with the biggest key being smaller than the one passed to the method. For element with equal or bigger key use .forward[0]
 */
public function search(intSearchKey:Number):Object {
	// init "cursor" element to header:
	var cursor:SkipListElement = this.myHeader;

	// find element in list:
	for (var i:Number=this.myLevel; i>=0; i--) {
		var nextElement:SkipListElement = SkipListElement(cursor.forward[i]);
		while (nextElement.key < intSearchKey){
			cursor = nextElement;
			nextElement = SkipListElement(cursor.forward[i]);
		}
	}
	return cursor;
}
//////////////////////////////////////////////////
// Inserting an Element
//
// The insert() method inserts a pair—a unique key and the
// associated value object—as a new element into the list.
// If there is already an element with that key in the list,
//  its value is replaced by the new value.
//
//  We first look for the position of insertion using the
// discussed search algorithm. Having found the position,
// we split the list and insert the new node; see Figure 3.
// In an array called update, we keep track of the preceding
// neighbor elements that will potentially point to the new element.
// Using this update array, pointers can easily be modified,
// so that our new node is integrated into the list.
// A small but important detail is how to determine the new node's level.
// It is automatically generated by a method I will discuss later on.
//  But let's have a closer look at how an insertion is done:

public function insert( item:SkipListElement ):void{
	var update:Vector.<SkipListElement> = new Vector.<SkipListElement> ( this.myMaxLevel+1, true );

	// init "cursor" element to header:
	var cursor:SkipListElement = this.myHeader;

	// find place to insert new node:
	for (var i:int = this.myLevel; i>=0; i--) {
		while ( cursor.forward[i].key < item.key ) {
			cursor = cursor.forward[i];
		}
		update[i] = cursor;
	}
	cursor = cursor.forward[0];

	// element with same key:
	if (cursor.key == item.key) {
		cursor.insertObjects ( item.values );
	} else {
	// or an additional element is inserted:
		var newLevel:Number = this.generateRandomLevel();
		// new element has highest level:
		if (newLevel > this.myLevel) {
			for ( i = this.myLevel + 1; i <= newLevel; i++ ) {
				update[i] = myHeader;
			}
			myLevel = newLevel;
		}
		
		// insert new element:
		cursor = item;
		cursor.forward = new Vector.<SkipListElement>(newLevel + 1, true); //TODO: check if +1 is needed
		for ( i = 0; i <= newLevel; i++ ) {
			cursor.forward[i] = update[i].forward[i];
			update[i].forward[i] = cursor;
		}
	}
}
//////////////////////////////////////////////////////////////////////
//      To determine the level of a new node, we make use of a probabilistic method.
//  This method should produce levels obeying the proportions seen in theory.
//  If you have a probability of 0.5, the return value should be 0 in 50% of the calls,
// 1 in 25%, 2 in 12.5%, and so on.
// Here is the code that does the job by using ActionScripts's randomizer that produces values between 0.0 and 1.0:

//protected int
public function generateRandomLevel():Number { //TODO: optimize
   var newLevel:Number = 0;
   while (newLevel<this.myMaxLevel && Math.random()<this.myProbability ){
		  newLevel++;
   }
  // trace("generateRandomLevel " + newLevel);
   return newLevel;
}

//////////////////////////////////////////////////////////////////////
// Deleting an Element
//
// The last basic operation is the deletion of an element with a specific key.
// As we did in insertion, we first have to search for the node to be deleted.
// Thus the deletion() method begins just as the code for insertion did.
//
// If a node with the key to be deleted is found, it has to be cut out of the list.
// Again, the nodes potentially pointing to the removed element are kept in the array update.
// These nodes are updated, so that they are pointing now to the successors
// of the removed element.
//
// Since we might have deleted the node of the highest level,
// we have to adjust the list level and the header.
// Here you see how all this is done in ActionScript:

public function remove(searchKey:Number):void {
	var update:Vector.<SkipListElement> = new Vector.<SkipListElement>(myMaxLevel+1, true);

	// init "cursor" element to header:
	var cursor:SkipListElement = this.myHeader;

	// find place to insert new node:
	for (var i:int=myLevel; i >= 0; i--) {
		  while (cursor.forward[i].key < searchKey) {
				 cursor = cursor.forward[i];
		  }
		  update[i] = cursor;
	}
	cursor = cursor.forward[0];
	// rebuild list without node:
	if (cursor.key == searchKey) {
		for ( i = 0; i <= myLevel; i++ ) {
			if ( update[i].forward[i] == cursor ) {
				update[i].forward[i] = cursor.forward[i];
			}
		}
		// correct level of list:
		while (myLevel--) myHeader.forward[myLevel].key = SkipList.NIL_KEY; //TODO: remove and fix level?
	}
}



}
}