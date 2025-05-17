theta=-pi: 0.01 :pi;

v=pi*sin(theta)+pi/2;
AF=abs(sin(3*v)./sin(v/2));

subplot(1,2,1)
plot(v,AF)
axis([-0.5*pi 1.5*pi 0 6]);
xlabel('v');
ylabel('|AF|');

subplot(1,2,2)
polarplot(theta,AF)
title('|AF| in polar coordinates')