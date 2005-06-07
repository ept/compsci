fun count f ([]) = 0
  | count f (x::xs) = if (f x) then 1 + count f xs
                               else     count f xs;

fun len 0 = [[]]
  | len n = (map (fn x=>1::x) (len(n-1))) @
            (map (fn x=>2::x) (len(n-1))) @
            (map (fn x=>3::x) (len(n-1)));

fun types([], ones, twos, threes) =
  let val on = if (ones > 0) then 1 else 0
      val tw = if (twos > 0) then 1 else 0
      val th = if (threes > 0) then 1 else 0
  in on+tw+th end
  | types(x::xs, ones, twos, threes) =
      if (x=1) then types(xs, ones+1, twos, threes) else 
      if (x=2) then types(xs, ones, twos+1, threes) else 
                    types(xs, ones, twos, threes+1);

count (fn x=> types(x,0,0,0) = 2) (len 4);

