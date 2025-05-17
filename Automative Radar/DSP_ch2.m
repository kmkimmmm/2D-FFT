x=[1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
h=[0,0,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,0,0,0,0];
n=0:size(x,2)-1;

figure(1)
subplot(2,1,1)
stem(n,x)

subplot(2,1,2)
stem(n,h)

figure(2)

%convolution이 아예 겹치지 않는 위치에서 시작한다는 것을 기억
y=conv(x,h);
y_shifted=circshift(y,[0,-1]);

stem(y_shifted)

disp(y_shifted)