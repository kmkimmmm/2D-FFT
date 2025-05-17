clear;
clc;


%% 기존 simulation parameter와 다르게 설정한 값 
% maximum range, velocity를 위해서는 늘려야 함 
% else, aliasing 발생

N = 128;                     % fast time 샘플 수 
T_chirp = 100e-6;            % chirp 폭 
%% 파라미터 
c = 3e8;                     % 빛의 속도 (m/s)
f_c = 77e9;                  % 중심 주파수 (77GHz)
B = 300e6;                   % 대역폭 (300MHz)
K = B / T_chirp;             % chirp rate (Hz/s)
P = 64;                      % slow time (chirp 수)
Ts = T_chirp / N;            % fast time 샘플링 주기
fs = 1 / Ts;                 % fast time 샘플링 주파수
lambda = c / f_c;            % 파장
prf = 1 / T_chirp;           % Pulse Repetition Frequency

%% 타겟 설정
targets = [
    20,  20;  % 타겟1: 20m, 20 mi/h
    10,  0    % 타겟2: 10m, 정지
];
num_targets = size(targets,1);   % 타겟 개수
vel_mps = targets(:,2) / 2.237;  % mi/h -> m/s
f_d = 2 * vel_mps / lambda;      % 도플러 주파수 

%% ndgrid 생성
% N x P의 ndgrid 생성
[nn, pp] = ndgrid((0:N-1)*Ts, (0:P-1)*T_chirp); 
                                             

%% 수신기 출력 신호 (IF 신호)
rx = zeros(N, P);

for k = 1:num_targets
    R_target = targets(k, 1);       % 현재 타겟의 거리
    v_target_mps = vel_mps(k);      % 현재 타겟의 속도 (m/s)
    fd_target = f_d(k);             % 현재 타겟의 도플러 주파수

    phi_target = 2*pi*( (2*K*R_target/c + fd_target)*nn + fd_target*pp + 2*f_c*R_target/c );

    rx = rx + exp(1j * phi_target);   % 모든 타겟에 대한 신호 합산 (NxP)
end

%%  2D FFT
rdm= fft2(rx, N, P); 

% 속도 축만 fftshift -> 음, 양의 주파수를 가지기 때문 = 음, 양의 상대속도를 가짐. 
% 거리 축은 양의 주파수 성분만 취하기 -> 음의 거리는 없음.
rdm = fftshift(rdm, 2);
rdm = rdm(1:N/2, :);

rdm = abs(rdm);
rdm = 20 * log10(rdm / max(rdm(:)) + eps); % dB 스케일 (eps 추가로 log10(0) 방지)
                                         % rdm은 (N/2 range_bins x P velocity_bins)

%%  거리 및 속도 축 생성
% 거리 축
range_resolution = c / (2*B);
range_axis = (0 : N/2 - 1) * range_resolution; % 미터 단위

% 속도 축
doppler_freq_resolution = prf / P; % Hz 단위
velocity_resolution_mps = doppler_freq_resolution * lambda / 2; % m/s 단위
velocity_axis_mps = (-P/2 : P/2 - 1) * velocity_resolution_mps; % m/s 단위
velocity_axis_mph = velocity_axis_mps * 2.237; % mi/h 단위

%%  plot
figure(1);
% 거리x속도에서 속도x거리 map을 위한 transpose
imagesc(range_axis, velocity_axis_mph, rdm');

xlabel('Range (m)');
ylabel('Velocity (mi/h)');
title('Range-Doppler Map');
axis xy; % Y축 방향을 아래에서 위로 (일반적인 그래프 형태)
colorbar;
grid on;
