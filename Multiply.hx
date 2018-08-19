import js.jquery.Helper.*;

class Multiply {

	static function main() {
		var count = 0;
		var juste = 0;
		var ok = J("#ok");
		var bad = J("#bad");
		var liste = new Map();
		ok.hide();
		bad.hide();
		function next() {
			var input = J("#mult input");
			input.off();
			input.val("");
			input.focus();

			if( count == 20 ) {
				haxe.Timer.delay(function() {
					js.Browser.alert("Résultat : "+juste+" / "+count);
					count = 0;
					juste = 0;
					liste = new Map();
					next();
				},2000);
				return;
			}
			count = count + 1;
			var a = 0, b = 0;
			while( true ) {
				a = [2,3,5][Std.random(3)];
				b = 2 + Std.random(9);
				var m = a+"x"+b;
				if( liste.exists(m) )
					continue;
				var m = b+"x"+a;
				if( liste.exists(m) )
					continue;
				break;
			}
			liste.set(a+"x"+b,true);

			J("#mult span").text(a+" x "+b);
			var found = false;
			var t = haxe.Timer.delay(function() {
				if( !found ) {
					bad.hide().show().hide(2000);
					next();
				}
			},15000);
			input.on("keyup",function(e) {
				var n = Std.parseInt(input.val());
				if( n == a * b ) {
					found = true;
					t.stop();
					juste = juste + 1;
					next();
					ok.hide().show().hide(2000);
				}
			});
		}
		js.Browser.alert("OK pour commencer");
		next();
	}

}