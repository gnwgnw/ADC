function [ x ] = gss( f, a, b, eps )
% golden section search to find the minimum of f on [a,b]

phi = (sqrt(5) - 1) / 2;

l = b - phi * (b - a);
r = a + phi * (b - a);

val_r = f(r);
val_l = f(l);

while abs(r - l) > eps
    if val_l < val_r
        b = r;
        r = l;
        l = b - phi * (b - a);
        val_r = val_l;
        val_l = f(l);
    else
        a = l;
        l = r;
        r = a + phi * (b - a);
        val_l = val_r;
        val_r = f(r);
    end
end

x = (a + b) / 2;
end

