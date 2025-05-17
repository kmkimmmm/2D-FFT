n = 0:15;
x = 0.84.^n;
y = circshift(x,5);
[c,lags] = xcorr(x,y);
subplot(1,3,1)
stem(x)
subplot(1,3,2)
stem(y)
subplot(1,3,3)
stem(lags,c)