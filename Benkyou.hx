import js.jquery.Helper.*;

typedef WordStat = {
	var gen : Int;
	var fault : Int;
	var success : Int;
}

class Benkyou {

	var output : String;
	var words : Map<String, WordStat>;
	var verbs : Array<{
		verb : String,
		temps : String,
		list : Array<String>,
	}>;

	function new() {
		words = getWords();
		verbs = getVerbs();
		verbs = [for( v in verbs ) if( v.verb != null ) v];
	}

	function getWords() {
		var words = haxe.Resource.getString("words.txt");
		var stats = try haxe.Unserializer.run(js.Browser.getLocalStorage().getItem("wordStats")) catch( e : Dynamic ) null;
		if( stats == null )
			stats = new Map<String,WordStat>();
		var m = new Map();
		for( w in words.split("\n") ) {
			var w = StringTools.trim(w);
			if( w == "" || m.exists(w) ) continue;
			var s = stats.get(w);
			if( s == null )
				s = {
					gen : 0,
					fault : 0,
					success : 0,
				};
			m.set(w, s);
		}
		return m;
	}

	function getVerbs() {
		return haxe.Json.parse(haxe.Resource.getString("verbs.json"));
	}

	function print() {
		output = "";

		write('<div class="content">');

		// NAMI

		var nami = js.Browser.document.URL.indexOf("nami") > 0;
		var WORDS, TENSE = 0;

		if( nami ) {

			WORDS = 6;

			var K = 4;
			title('Additions');
			for( i in 0...K ) {
				var a = random(1,20);
				var b = random(1,30);
				inputNumber('$a + $b =', a + b);
			}
			end();

		} else {

			// MIO

			var K = 2;
/*
			title('Additions');
			for( i in 0...K ) {
				var a = random(10,80);
				var b = random(10,99 - a);
				inputNumber('$a + $b =', a + b);
			}
			end();

			title('Soustractions');
			for( i in 0...K ) {
				var a = random(10,40);
				var b = random(2,9);
				inputNumber('$a - $b =', a - b);
			}
			end();
*/
			var MULT = 8;

			title('Multiplications');
			for( i in 0...MULT ) {
				var a = random(2,5);
				var b = random(2,9);
				if( Std.random(2) == 0 ) {
					var tmp = a;
					a = b;
					b = tmp;
				}
				inputNumber('$a x $b =', a * b);
			}
			end();

			WORDS = 0;
			TENSE = 6;

		}

		if( WORDS > 0 ) {
			title('Dictée');
			var wlist = [for( w in words.keys() ) { var s = words.get(w); { w : w, p : 1 / (4 + s.gen), s : s } }];
			for( i in 0...WORDS ) {
				var w = randomList(wlist);
				w.s.gen++;
				inputWord(w.w);
			}
			end();
		}

		if( TENSE > 0 ) {
			title("Temps");
			var pre = [["je"],["tu"],["il","elle"],["nous"],["vous"],["ils","elles"]];
			for( i in 0...TENSE ) {
				var v = verbs[Std.random(verbs.length)];
				var k = Std.random(pre.length);
				var pre = pre[k];
				var pre = pre[Std.random(pre.length)];
				var ans = v.list[k];
				if( pre == "je" && "aeiouéà".indexOf(ans.charAt(0)) >= 0 )
					pre = "j'";
				write('<tr><td colspan="2"><i>${v.verb} ${v.temps}</i></td></tr><tr><td>$pre</td><td><input type="text" answer="$ans"/> <span class="hide" title="$ans">[?]</span></td></tr>');
			}
			end();
		}

		write("<br/><br/><br/><input type='button' id='check' value='Corriger'/>");

		write('</div>');

		js.Browser.document.write(output);
		J("#check").click(check);
	}

	function check(_) {
		J(".correct").removeClass("correct");
		J(".fault").removeClass("fault");
		J(".almost").removeClass("almost");
		J(".reveal").removeClass("reveal");
		var allOK = true;
		for( e in J("input[type=number]").elements() ) {
			if( e.val() == Std.parseInt(e.attr("answer")) ) {
				e.addClass("correct");
			} else {
				allOK = false;
				if( e.val() == 0 ) continue;
				e.addClass("fault");
			}
		}
		for( e in J("input[type=text]").elements() ) {
			var v = StringTools.trim(e.val()).toLowerCase();
			if( v == "" ) {
				allOK = false;
				continue;
			}
			var answer = e.attr("answer").toLowerCase();
			if( v == answer ) {
				e.addClass("correct");
			} else {
				allOK = false;
				e.parent().parent().addClass("reveal");
				if( removeAccents(v) == removeAccents(answer) )
					e.addClass("almost");
				else
					e.addClass("fault");
			}
		}
		if( allOK )
			new js.html.Audio('bravo.mp3').play();
	}

	function removeAccents( s : String ) {
		var o = "";
		for( i in 0...s.length )
			o += switch( s.charAt(i) ) {
			case "é", "è", "ê": "e";
			case "à": "a";
			case "ô": "o";
			case "ç": "c";
			case x: x;
			}
		return o;
	}

	var prev = [];

	function random(start:Int, end:Int) {
		var k = end - start + 1;
		while( true ) {
			if( prev.length >= k ) {
				while( prev.length > (k >> 1) )
					prev.shift();
			}
			var x = start + Std.random(k);
			if( prev.indexOf(x) < 0 ) {
				prev.push(x);
				return x;
			}
		}
	}

	function randomList<T:{p:Float}>( a : Array<T> ) : T {
		var tot = 0.;
		for( v in a ) tot += v.p;
		var k = Math.random() * tot;
		for( v in a ) {
			k -= v.p;
			if( k < 0 ) return v;
		}
		return null;
	}

	function write(str) {
		output += str;
	}

	function title(name:String){
		write('<table class="section"><tr><th colspan="2">$name</th></tr>');
	}

	function end() {
		write('</table>');
	}

	function inputNumber( text : String, answer : Int ) {
		write('<tr><td><pre>$text</pre></td><td><input type="number" answer="$answer"/></td></tr>');
	}

	function inputWord( word : String ) {
		write('
		<tr>
			<td><div class="talk" word="$word" onclick="responsiveVoice.speak(this.getAttribute(\'word\'),\'French Female\',{rate:0.8})">&#x25BA;</div></td>
			<td><input type="text" spellcheck="false" answer="$word"/> <span class="hide" title="$word">[?]</span></td>
		</tr>
		');
	}

	static function main() {
		new Benkyou().print();
	}

}