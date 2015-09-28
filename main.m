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
% Filter design
%

Fs = freq;      % Sampling Frequency
Fpass = 1;      % Passband Frequency
Fstop = 20;     % Stopband Frequency
Apass = 0.1;	% Passband Ripple (dB)
Astop = 80;	% Stopband Attenuation (dB)

h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
Hd = design(h, 'ellip');

%%

X = filter(Hd, X_filth);
Y = filter(Hd, Y_filth);
P = filter(Hd, P_filth);

%%

figure(1);
hold on;

plot(T, X);
plot(T, Y);
plot(T, X_filth);
plot(T, Y_filth);

%%

figure(2);
hold on;

plot(T, P);
plot(T, P_filth);

%%

figure(3);
hold on;
grid on;
axis equal;

plot(X, Y);