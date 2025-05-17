T_s=0.01; %sampling period 0.01
f_s=1/T_s; %sampling 
t0=T_s:T_s:1;
y0=sin(100*t0);
f_c=100/(2*pi);

figure(1)
plot(t0,y0);
title('T_s=0.01');

N_fft=2^10;
y0_fft=fft(y0, N_fft);
d0=1/N_fft*f_s;

figure(2)
plot((1:N_fft/2)*d0 , abs(y0_fft(1:N_fft/2)));