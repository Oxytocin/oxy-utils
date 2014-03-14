package  {
	
import flash.display.MovieClip;
import flash.utils.getDefinitionByName;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.events.Event;

public class IsoMath extends MovieClip {
	
	private static const FIELD_WIDTH:int = 10;
	private static const FIELD_HEIGHT:int = 10;
	
	private static const CART_TILE_WIDTH:Number = 30;
	private static const CART_TILE_HEIGHT:Number = 30;
	
	private static const ISO_TILE_WIDTH:Number = 40;
	private static const ISO_TILE_HEIGHT:Number = 30;
	
	private var tileClass:Class;
	private var heroClass:Class;
	
	private var cartField:MovieClip;
	private var isoField:MovieClip;
	
	private var cartHero:MovieClip;
	private var isoHero:MovieClip;
	
	private var conv:CoordinatesConverter;
	
	public function IsoMath() {
		tileClass = getDefinitionByName("mc_tile") as Class;
		
		heroClass = getDefinitionByName("mc_hero") as Class;
		
		createCartField();
		createIsoField();
		
		conv = new CoordinatesConverter();
		conv.init(CART_TILE_WIDTH, CART_TILE_HEIGHT, ISO_TILE_WIDTH, ISO_TILE_HEIGHT);
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(event:Event):void {
		update();
	}
	
	private function createCartField():void {
		cartField = new MovieClip();
		for (var i:int = 0; i < FIELD_HEIGHT; i++) {
			for (var j:int = 0; j < FIELD_WIDTH; j++) {
				var tile:MovieClip = new tileClass();
				tile.gotoAndStop(1 + (i + j) % 2);
				tile.width = CART_TILE_WIDTH;
				tile.height = CART_TILE_HEIGHT;
				tile.x = j * CART_TILE_WIDTH;
				tile.y = i * CART_TILE_HEIGHT;
				cartField.addChild(tile);
			}
		}
		addChild(cartField);
		cartField.x = 100;
		cartField.y = 100;
		
		cartField.addEventListener(MouseEvent.CLICK, onCartFieldClick);
		
		cartHero = new heroClass();
		cartHero.scaleX = cartHero.scaleY = 0.6;
		cartField.addChild(cartHero);
	}
	
	private function createIsoField():void {
		isoField = new MovieClip();
		
		for (var i:int = 0; i < FIELD_HEIGHT; i++) {
			for (var j:int = 0; j < FIELD_WIDTH; j++) {
				var tile:MovieClip = new tileClass();
				tile.gotoAndStop(3 + (i + j) % 2);
				tile.x = ISO_TILE_WIDTH / 2 * (j - i);
				tile.y = ISO_TILE_HEIGHT / 2 * (i + j);
				tile.width  = ISO_TILE_WIDTH;
				tile.height = ISO_TILE_HEIGHT;
				isoField.addChild(tile);
			}
		}
		
		addChild(isoField);
		isoField.x = 700;
		isoField.y = 100;
		
		isoField.addEventListener(MouseEvent.CLICK, onIsoFieldClick);
		
		isoHero = new heroClass();
		isoField.addChild(isoHero);
		isoHero.scaleX = isoHero.scaleY = 0.5;
	}
	
	private function onCartFieldClick(event:MouseEvent):void {
		moveCartHero(cartField.mouseX, cartField.mouseY);
	}
	
	private function onIsoFieldClick(event:MouseEvent):void {
		trace("Iso field clicked");
		moveIsoHero(isoField.mouseX, isoField.mouseY);
	}
	
	private var dstCart:Point = null;
	private var angle:Number;
	
	private var speedx:Number;
	private var speedy:Number;
	
	private function moveCartHero(cartX:Number, cartY:Number):void {
		dstCart = new Point(cartX, cartY);
		angle = Math.atan2((cartY - cartHero.y), (cartX - cartHero.x));
		speedx = SPEED * Math.cos(angle);
		speedy = SPEED * Math.sin(angle);
	}

	private function moveIsoHero(isoX:Number, isoY:Number):void {
		var dst:Point = conv.iso2cart(isoX, isoY);
		moveCartHero(dst.x, dst.y);
	}

	private static const SPEED:Number = 5;

	private function update() {
		if (dstCart != null) {
			var dst:Number = Point.distance(dstCart, new Point(cartHero.x, cartHero.y));
			if (dst <= SPEED) {
				cartHero.x = dstCart.x;
				cartHero.y = dstCart.y;
				dstCart = null;
			} else {
				cartHero.x += speedx;
				cartHero.y += speedy;
			}
			var isoPos:Point = conv.cart2iso(cartHero.x, cartHero.y);
			isoHero.x = isoPos.x;
			isoHero.y = isoPos.y;
		}
	}
}	
}
import flash.geom.Point;

class CoordinatesConverter {
	
	private var _initialized:Boolean = false;
	
	public function CoordinatesConverter() {
		
	}
	
	private var _dx0:Number;
	private var _dx1:Number;
	
	private var _dy0:Number;
	private var _dy1:Number;
	
	public function init(cartTileWidth:Number, cartTileHeight:Number, isoTileWidth:Number, isoTileHeight:Number):void {
		_initialized = true;
		
		_dx0 = cartTileWidth;
		_dy0 = cartTileHeight;
		
		_dx1 = isoTileWidth;
		_dy1 = isoTileHeight;
	}
	
	public function cart2iso(x:Number, y:Number):Point {
		if (!_initialized) {
			throw new Error("Converter is not initialized");
		}
		var res:Point = new Point();
		res.x = _dx1 / 2 * (x / _dx0 - y / _dy0);
		res.y = _dy1 / 2 * (x / _dx0 + y / _dy0);
		return res;
	}
	
	public function iso2cart(x:Number, y:Number):Point {
		if (!_initialized) {
			throw new Error("Converter is not initialized");
		}
		var res:Point = new Point();
		res.x = _dx0 * (x / _dx1 + y / _dy1);
		res.y = _dy0 * (y / _dy1 - x / _dx1);
		return res;
	}
}