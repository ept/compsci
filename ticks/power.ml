fun power_it(x,n) =
    let fun f(i,q,p): real =
        if i=0 then p else
        if (i mod 2) = 0 then f(i div 2, q*q, p) else f(i div 2, q*q, p*q)
    in
        f(n, x, 1.0)
    end;
