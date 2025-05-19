clc; clear;

%% === 파라미터 설정 ===
fc = 79e9;                  % 중심 주파수 [Hz]
c = 3e8;                    % 빛의 속도 [m/s]
lambda = c / fc;            % 파장 [m]
Tc = 2e-9;                  % 칩 간격 [s]
M = 256;                    % 칩 수 (range 방향)
L = 256;                    % 시퀀스 수 (doppler 방향)

R_target = 20;              % 타겟 거리 [m]
v_target = 12;              % 타겟 속도 [m/s]
fd = 2 * v_target / lambda; % 도플러 주파수 [Hz]
delay_idx = round(2 * R_target / (c * Tc));  % 거리 인덱스

%% === PN 시퀀스 생성 ===
% Q : PN sequence 생성기를 사용하면 하모닉마냥 range의 특정 배수에 peak가 발견 됨
% 왜이러지?

% pn_generator = comm.PNSequence( ...
%     'Polynomial',[6 1 0], ...
%     'InitialConditions',[1 0 1 1 0 1 ], ...
%     'Mask',[1 1 0 1 0 1], ...
%     'SamplesPerFrame',M);
% 
% chip_sequence = step(pn_generator);
% tx_seq = 2 * chip_sequence - 1;
% tx_seq=tx_seq';

%% === 송신 신호 생성 ===
tx_seq = randi([0 1], 1, M) * 2 - 1; 

%% === 수신 신호 생성 ===
rx_sig = zeros(L, M);
for l = 1:L
    phase_shift = exp(1j * 2 * pi * fd * Tc * ((l-1)*M + (0:M-1)));
    shifted = circshift(tx_seq, [0, delay_idx]) .* phase_shift;
    rx_sig(l, :) = shifted;
end

% === 2D cross-correlation (range 추정) ===
rd_corr = zeros(M, L);
for l = 1:L
    corr = xcorr(rx_sig(l,:), tx_seq);
    rd_corr(:, l) = abs(corr(M:end));
end

%% === 도플러 추정 FFT ===
RD = abs(fftshift(fft(rd_corr, [], 2), 2));  % 열 방향 FFT

% === 축 계산 ===
range_axis = (0:M-1) * c * Tc / 2;  % 거리 축
vel_axis = linspace(-1, 1, L) * (1 / (2 * M * Tc)) * lambda;  % 속도 축

% === 최대 피크 탐지 ===
[max_val, linear_idx] = max(RD(:));
[row_peak, col_peak] = ind2sub(size(RD), linear_idx);
peak_range = range_axis(row_peak);
peak_velocity = vel_axis(col_peak);

% === 3D Surface Plot ===
[VEL, RANGE] = meshgrid(vel_axis, range_axis);
figure;
surf(VEL, RANGE, RD, 'EdgeColor', 'none');
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Amplitude');
title('3D Range-Doppler Map');
colorbar;
view(45, 30);

% === 피크 위치 표시 ===
hold on;
plot3(peak_velocity, peak_range, max_val, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(peak_velocity, peak_range, max_val, sprintf(' Peak: %.1f m, %.1f m/s', peak_range, peak_velocity), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', 'red');
