function [ max_corr ] = max_corr( X, Y, C )

    X = X + C(1);
    Y = Y + C(2);

    G = complex(X, Y);
    phi = unwrap(angle(G));
    u = diff(phi);

%     Xcorr = max(abs(xcorr(u, X)));
    Ycorr = max(abs(xcorr(u, Y)));

%     max_corr = Xcorr + Ycorr;
    max_corr = Ycorr;
end

