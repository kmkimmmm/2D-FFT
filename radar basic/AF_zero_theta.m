theta=-pi : 0.01 : pi;
v=1.2*pi*sin(theta);
AF=(sin(5*v/2)./(v/2));

figure(1)
subplot(1,2,1)
plot(v,abs(AF))
axis([-1.2*pi 1.2*pi 0 5]);
xlabel('v');
ylabel('|AF|')

subplot(1,2,2)
polarplot(theta,abs(AF))
title('|AF| in polar coordinates')