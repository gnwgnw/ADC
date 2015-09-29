WINDOW_WIDTH = 10000;
FREQ = 102400;
SPREAD = 10;
freq = FREQ / SPREAD;

%% 

M = dlmread('out.txt', '', 1, 0);

%%

T = M(1:SPREAD:end, 1);
X_filth = M(1:SPREAD:end, 2);
Y_filth = M(1:SPREAD:end, 3);
P_filth = M(1:SPREAD:end, 4);


%%

X = accept_filter(X_filth, freq);
Y = accept_filter(Y_filth, freq);
P = accept_filter(P_filth, freq);

%%

G = complex(X, Y);

%%

figure(1);
hold on;

plot(T, X_filth);
plot(T, Y_filth);
plot(T, X);
plot(T, Y);

%%

figure(2);
hold on;

plot(T, P_filth);
plot(T, P);

%%

figure(3);
hold on;
grid on;
axis equal;

plot(G);

%%

phi = unwrap(angle(G));

%%

figure(4);
hold on;

plot(T, phi);

%%

u = diff(phi) .* freq;

%%

figure(5);
hold on;

plot(T(1:end-1), u);