% LFM 파형 생성
% 파라미터 설정
fs = 1e6;            % 샘플링 주파수 (1 MHz)
T_s = 1e-3;          % Sweep Time (1 ms)
B = 1e5;             % 대역폭 (100 kHz)
f_start = 1e3;       % 시작 주파수 (1 kHz)
t = 0:1/fs:T_s-1/fs; % 시간 벡터

% LFM 신호 생성
k = B / T_s;         % 주파수 변화율 (slope)
f_t = f_start + k * t; % 순간 주파수 (time-dependent frequency)
lfm_signal = exp(1j * 2 * pi * (f_start * t + (k/2) * t.^2));

% 실수 및 복소 신호 분리
lfm_real = real(lfm_signal);
lfm_imag = imag(lfm_signal);

% 그래프 출력
figure;
subplot(3,1,1);
plot(t, f_t/1e3); % 주파수 변화 시각화 (kHz)
title('LFM Signal - Instantaneous Frequency');
xlabel('Time (s)');
ylabel('Frequency (kHz)');

grid on;

subplot(3,1,2);
plot(t, lfm_real);
title('LFM Signal - Real Part');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot(t, lfm_imag);
title('LFM Signal - Imaginary Part');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 주파수 스펙트럼 확인
L = length(lfm_signal);
frequencies = (-L/2:L/2-1)*(fs/L); % 주파수 축
y_fft = fftshift(fft(lfm_signal));

figure;
plot(frequencies/1e3, abs(y_fft));
title('LFM Signal Spectrum');
xlabel('Frequency (kHz)');
ylabel('Magnitude');
grid on;
