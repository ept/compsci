fun poss (x,1) = if (x > 0) andalso (x < 7) then 1 else 0
  | poss (x,n) = poss(x-1,n-1) +
                 poss(x-2,n-1) +
                 poss(x-3,n-1) +
                 poss(x-4,n-1) +
                 poss(x-5,n-1) +
                 poss(x-6,n-1);

fun dice_ (_, 0, _) = ([1], 1)
  | dice_ (max, k, n) =
    let val (xs,sum) = dice_(max, k-1, n)
        val p = poss(max-k, n)
    in  (p::xs, sum+p) end;

fun dice n = dice_(6*n, 6*n, n);

