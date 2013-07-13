package ryz.utils;
import haxe.ds.StringMap;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;

/**
 * ...
 * @author ryz
 */

using haxe.macro.Context;
 
class LambdaMacro
{
	
	static function arrowDecompose(f:Expr)
	{
		// need find left and right values in f
		// left - ident
		// right - expr
		
		var l:Expr = null;
		var r:Expr = null;
		
		switch(f.expr)
		{
			case EBinop(OpArrow, e1, e2):
			{
				l = e1;
				r = e2;
			}
			default: r = f;
		}
		
		return { L:l, R:r };
	}
	static function leftName(L:Expr)
	{
		return leftNames(L)[0];
	}
	static function leftNames(L:Expr, min:Int = 1)
	{
		var names:Array<String> =
			if (L != null)
			{
				switch(L.expr)
				{
					case EConst(CIdent(s)): [s];
					case EArrayDecl(els): els.map(function(e)
						return switch(e.expr)
						{
							case EConst(CIdent(s)): s; 
							default: '_';
						});
					case _: [];
				}
			}
			else [];
		
		var t = '';
		while (names.length < min) names.push(t += '_');
		return names;
	}
	
	static function tempVarNames(cnt:Int, locals:StringMap<Type>):Array<String>
	{
		var r = new Array<String>();
		var tmap = new StringMap<Int>();
		
		while (r.length < cnt)
		{
			var t = '__tmp_' + Std.random(0xffffff);
			if (!locals.exists(t) && !tmap.exists(t))
			{
				r.push(t);
				tmap.set(t, 1);
			}
		}
		return r;
	}
	
	
	macro public static function array(a:Expr):Expr
	{
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var tNames = tempVarNames(2, Context.getLocalVars());
		var out = tNames.pop();
		var itv = tNames.pop();
		
		return macro
		{
			var $out = new Array<$outType>();
			for ($i{itv} in $a) $i{out}.push($i{itv});
			$i{out};
		}
	}
	
	
	macro public static function list(a:Expr):Expr
	{
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var tNames = tempVarNames(2, Context.getLocalVars());
		var out = tNames.pop();
		var itv = tNames.pop();
		
		return macro
		{
			var $out = new List<$outType>();
			for ($i{itv} in $a) $i{out}.add($i{itv});
			$i{out};
		}
	}

	

	macro public static function count(a:Expr, pred:Expr):Expr
	{
		var fDec = arrowDecompose(pred);
		var lName = leftName(fDec.L);
		var rVal = fDec.R;
		
		var tNames = tempVarNames(1, Context.getLocalVars());
		var cnt = tNames.pop();
		
		return macro
		{
			var $cnt = 0;
			for ($i{lName} in $a)
			{
				if ($rVal) $i{cnt} += 1; // cant use "++", dunno why
			}
			$i{cnt};
		}
	}

	
	
	macro public static function map(a:Expr, f:Expr):Expr
	{
		var fDec = arrowDecompose(f);
		var lName = leftName(fDec.L);
		var rVal = fDec.R;
		
		
		var outType = (macro
		{
			var $lName = $a.iterator().next();
			var bVal = $rVal;
			bVal;
		}).typeof().toComplexType();
		
		
		var tNames = tempVarNames(1, Context.getLocalVars());
		var out = tNames.pop();
		
		
		return macro
		{
			var $out = new List<$outType>();
			for ($i{lName} in $a) $i{out}.add($rVal);
			$i{out};
		}
	}
	

	
	macro public static function mapi(a:Expr, f:Expr):Expr
	{
		var fDec = arrowDecompose(f);
		
		var lNames = leftNames(fDec.L, 2);
		var lNameIndex = lNames.shift();
		var lNameValue = lNames.shift();
		
		var rVal = fDec.R;
		var outType = (macro
		{
			var $lNameValue = $a.iterator().next();
			var $lNameIndex = 0;
			var bVal = $rVal;
			bVal;
		}).typeof().toComplexType();
		
		
		var tNames = tempVarNames(1, Context.getLocalVars());
		var out = tNames.pop();
		
		return macro
		{
			var $out = new List<$outType>();
			var $lNameIndex = 0;
			for ($i{lNameValue} in $a) 
			{
				$i{out}.add($rVal);
				$i{lNameIndex} += 1; // cant use "++", same as count
			}
			$i{out};
		}
	}
	
	
	
	macro public static function has(a:Expr, b:Expr):Expr
	{
		var tNames = tempVarNames(2, Context.getLocalVars());
		var answer = tNames.pop();
		var itv = tNames.pop();

		return macro
		{
			var $answer = false;
			for ($i{itv} in $a)
			{
				if ($i{itv} == $b)
				{
					$i{answer} = true;
					break;
				}
			}
			$i{answer};
		}
	}

	macro public static function exists(a:Expr, f:Expr):Expr
	{
		var fdec = arrowDecompose(f);
		var lName = leftName(fdec.L);
		var rVal = fdec.R;
		
		
		var tNames = tempVarNames(1, Context.getLocalVars());
		var answer = tNames.pop();

		
		return macro
		{
			var $answer = false;
			for ($i{lName} in $a)
			{
				if ($rVal)
				{
					$i{answer} = true;
					break;
				}
			}
			$i{answer};
		}
	}
	
	
	
	macro public static function foreach(a:Expr, f:Expr):Expr
	{
		var fdec = arrowDecompose(f);
		var lName = leftName(fdec.L);
		var rVal = fdec.R;
		
		
		var tNames = tempVarNames(1, Context.getLocalVars());
		var answer = tNames.pop();

		
		return macro
		{
			var $answer = true;
			for ($i{lName} in $a)
			{
				if (!$rVal)
				{
					$i{answer} = false;
					break;
				}
			}
			$i{answer};
		}
	}

	
	macro public static function iter(a:Expr, f:Expr):Expr
	{
		var fdec = arrowDecompose(f);
		var lName = leftName(fdec.L);
		var rVal = fdec.R;
		
		return macro
		{
			for ($i{lName} in $a) $rVal;
		}
	}
	
	
	macro public static function filter(a:Expr, f:Expr):Expr
	{
		var fDec = arrowDecompose(f);
		var lName = leftName(fDec.L);
		var rVal = fDec.R;
		
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		
		var tNames = tempVarNames(1, Context.getLocalVars());
		var out = tNames.pop();
		
		
		return macro
		{
			var $out = new List<$outType>();
			for ($i{lName} in $a)
			{
				if($rVal) $i{out}.add($i{lName});
			}
			$i{out};
		}
	}
	
	
	
	
	
	macro public static function countAny(a:Expr):Expr
	{
		var tNames = tempVarNames(2, Context.getLocalVars());
		var cnt = tNames.pop();
		var it = tNames.pop();
		
		return macro
		{
			// using while instead for, coz we dont need value of it.next()
			// hope it can be a little faster
			var $cnt = 0;
			var $it = $a.iterator(); 
			while ( $i{it}.hasNext() )
			{
				$i{it}.next();
				$i{cnt} += 1; // cant use "++"
			}
			$i{cnt};
		}
	}

	
	
	macro public static function empty(a:Expr):Expr
	{
		return macro !$a.iterator().hasNext();
	}
	
	
	
	macro public static function indexOf(a:Expr, b:Expr):Expr
	{
		var tNames = tempVarNames(3, Context.getLocalVars());
		var answer = tNames.pop();
		var counter = tNames.pop();
		var itv = tNames.pop();
		
		return macro
		{
			var $answer = -1;
			var $counter = 0;
			for ($i{itv} in a)
			{
				if ($i{itv} == $b)
				{
					$i{answer} = $i{counter};
					break;
				}
				$i{counter} += 1;
			}
			$i{answer};
		}
	}
	
	
	
	macro public static function concat(a:Expr, b:Expr):Expr
	{
		var outType = (macro $a.iterator().next()).typeof().toComplexType();
		
		var tNames = tempVarNames(2, Context.getLocalVars());
		var out = tNames.pop();
		var itv = tNames.pop();
		
		return macro
		{
			var $out = new List<$outType>();
			for ($i{itv} in $a) $i{out}.add($i{itv});
			for ($i{itv} in $b) $i{out}.add($i{itv});
			$i{out};
		}
	}

}