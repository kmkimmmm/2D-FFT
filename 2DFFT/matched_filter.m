clear, clc
%matched filter

%parameter
fs = 1e3;          %sampling frequency        
t = 0:1/fs:0.1;     %time
w = 20e-3;          %pulse width
t0 = 40e-3;         %received time
Ts=1/fs;            %sampling period
c=3e8;              %speed of light
tau0=50e-3;         %system delay
    
% transmit signal, noise signal
origin_pulse=rectpuls(t-w/4,w/2);
x = rectpuls(t-t0-w/4,w/2);
ni = 0.2*randn(1,length(t));

% radar incident signal(transmit signal+noise)
xi=x+ni;
figure(1);
subplot(3,1,1)
plot(t,origin_pulse)
grid on
title('Noiseless Transmit signal')
xlabel('time[s]')
ylabel('amplitude')
ylim([0,2])

subplot(3,1,2)
plot(t,ni)
grid on
title('Noise Signal')
xlabel('time[s]')
ylabel('amplitude')

subplot(3,1,3)
plot(t,xi)
grid on
title('Received Signal')
xlabel('time[s]')
ylabel('amplitude')

%matched filter output
figure(2)
h=2/w*rectpuls(-t-w/4-t0+tau0,w/2);
y=Ts*conv(xi,h,'full');

t_y=(0:length(y)-1)*Ts;

%finding maximum value
[max_y,max_idx]=max(y);
max_time=t_y(max_idx);


subplot(2,1,1)
plot(t,h)
grid on
title('matched filter')
xlabel('time[s]')
ylabel('amplitude')
ylim([min(h),max(h)+10])


%output of matched filter
subplot(2,1,2)
plot(t_y,y)
hold on
plot(max_time,max_y, 'ro', 'MarkerSize',8,'LineWidth',2)
text(max_time+0.001, max_y-0.0005, sprintf(' max at %.3f s', max_time))
hold off
grid on
title('result of matched filter')
xlabel('time[s]')
ylabel('amplitude')
xlim([0,0.1])
ylim([min(y)-0.1,max(y)+0.1])

