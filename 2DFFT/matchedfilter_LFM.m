clear, clc
% Matched Filter with LFM Signal

j = sqrt(-1);
% Parameter
fs = 1e6;           % Sampling frequency
Ts = 1/fs;          % Sampling period
w = 50e-3;          % Sweep time
t = 0:Ts:0.1;       % Time
t_lfm = 0:Ts:w;     % Sweep time
t0 = 40e-3;         % Received time
t0_idx = round(t0 * fs); % Index of t0
c = 3e8;            % Speed of light
B = 1e3;            % LFM bandwidth (Hz)
fc = 1e4;           % Center frequency (Hz)
tau0=w+t0;          %system delay
tau0_idx=round(tau0*fs);    %index of tau0


% Transmit signal (LFM)
k = B / w;          % Chirp rate (Hz/s)
complex_envx = exp(j * pi * k * t_lfm.^2);
complex_envx_result = [complex_envx, zeros(1, length(t) - length(complex_envx))];

%energy of transmit signal
Ex=w*sum(abs(complex_envx_result).^2);

% Receive signal (LFM)
receive_envx = [zeros(1, t0_idx), complex_envx, zeros(1, length(t) - t0_idx - length(complex_envx))];
xi=exp(-j*2*pi*fc*t0)*receive_envx;

% Matched filter
h = conj(flip(xi, 2));

%system delay Matched Filter
i_h=Ex*h(length(t)-tau0_idx:length(t)-t0_idx);
hh=[i_h,zeros(1,length(t)-length(i_h))];

% Matched filter output
y = Ts*conv(xi, h, 'full');
l_y=length(y);
t_y = ((-length(y)+1)/2:(length(y)-1)/2) * Ts ;

% System delayed Matched filter output
yy=Ts*conv(xi,hh,'full');
l_yy=length(yy);
t_yy=((-length(yy)+1)/2:(length(yy)-1)/2) * Ts ;

% Visualization
figure(1);
subplot(2,1,1);
plot(t, real(complex_envx_result));
xlabel('Time [s]');
ylabel('amplitude')
title('Transmit Signal(Real Part)');
ylim([-1.5,1.5])
grid on;

subplot(2,1,2);
plot(t, real(xi));
xlabel('Time [s]');
ylabel('amplitude')
title('Received Signal(Real Part)');
ylim([-1.5,1.5])
grid on;

% subplot(4,1,3)
% plot(flip(-t),real(h))
% grid on
% xlabel('Time [s]')
% ylabel('amplitude')
% title('Matched Filter')
% ylim([-1.5 1.5])
% 
% subplot(4,1,4)
% plot(t,real(hh))
% grid on
% xlabel('Time[s]')
% ylabel('amplitude')
% title('causal Matched Filter')
% ylim([-1.5,1.5])

figure(2);
% subplot(2,1,1)
% plot(t_y,real(y))
% hold on
% plot(max_ty,max_y,'ro','MarkerSize',8,'LineWidth',2)
% text(max_ty+0.001, max_y-0.01,sprintf(' max at %2f s',max_ty))
% hold off
% xlabel('Time [s]')
% ylabel('amplitude')
% title('Matched Filter Output')
% grid on;

%db scale
db_scale = abs(yy);
db_scale = (db_scale-min(db_scale(:)))/(max(db_scale(:))-min(db_scale(:)));
db_scale = 20*log10(db_scale);

%max
[max_yy,max_yyidx]=max(db_scale);

max_tyy=t_yy(max_yyidx)+0.1;

%3dB bandwidth threshold
threshold = max_yy - 3;
idx_3dB = find(db_scale >= threshold);

%3dB bandwidth
bandwidth_start = t_yy(min(idx_3dB)) + 0.1;
bandwidth_end = t_yy(max(idx_3dB)) + 0.1;

t_duration=abs(bandwidth_end-bandwidth_start);
display(t_duration)

plot(t_yy+0.1,db_scale); %real(yy)
ylim([-40 0 ]);
hold on
plot(max_tyy,max_yy,'ro','MarkerSize',8,'LineWidth',2)
text(max_tyy+0.001, max_yy-2,sprintf(' max at %2f s',max_tyy))
plot([bandwidth_start, bandwidth_end], [threshold, threshold], 'g--', 'LineWidth', 2);
% text(bandwidth_start - 0.002, threshold - 5, sprintf('3dB BW Start: %.5f s', bandwidth_start));
% text(bandwidth_end + 0.002, threshold - 5, sprintf('3dB BW End: %.5f s', bandwidth_end));
text(max_tyy, max_yy-5, sprintf(' effective duration: %3f',t_duration));
hold off
xlabel('Time[s]');
ylabel('amplitude[dB]')
title('Causal Matched Filter Output')
grid on;




