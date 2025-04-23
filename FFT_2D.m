clear;
clc;

%% === 파라미터 설정 ===
c = 3e8;                      % 빛의 속도 (m/s)
f_c = 77e9;                   % 중심 주파수 (77GHz)
B = 300e6;                    % 대역폭 (300MHz)
T_chirp = 300e-6;             % chirp 기간 (300us)
K = B / T_chirp;              % chirp rate (Hz/s)
N = 64;                       % fast time 샘플 수
P = 64;                       % slow time (chirp 수)
fs = N / (T_chirp);           % 샘플링 주파수 계산
lambda=c/f_c;                 % 파장
prf=1/T_chirp;
Ts=1/fs;

%% === 타겟 설정 ===
% [거리(m), 속도(mi/h)]
targets = [
    20,  20;     % 타겟1: 20m, 20 mi/h
    10,  0       % 타겟2: 10m, 정지
];

num_targets = size(targets,1);  % 타겟 개수
vel= targets(:,2)/2.237;      %mi/h -> m/s

f_d = 2 * vel / lambda;  % 도플러 주파수

% disp(vel)

%% === 시간 인덱스 생성 ===
n = 1:N; p = 1:P;
[n_mat, p_mat] = meshgrid(n, p);

% disp(n_mat)
% disp(p_mat)

%% === 수신 신호 생성 ===
rx = zeros(N, P);   % 수신 신호 초기화

for k = 1:num_targets
    R = targets(k, 1);        % 거리
    v = vel(k, 1);            % 속도
    f_dd = f_d(k,1);          % 도플러 주파수

    % 위상 구성
    phi = 2 * pi * ( ...
        2 * f_c * R / c + ...
        f_dd * (p_mat-1) * T_chirp + ...
        n_mat * Ts * (2 * K * R / c + f_dd));

    rx = rx + exp(1j * phi);   % 타겟별 신호 합산
end

% disp(rx)
%% === 2D FFT ===
rdm = abs(fftshift(fft2(rx, N, P),1));  
rdm = 20 * log10(rdm / max(rdm(:)));  % dB 스케일(max 값으로 나눠줌)

%% === 거리 및 속도 축 생성 ===
f1=(1/N)*fs;  % frequency resolution for n
f2=(1/P)*prf; % frequency resolution for p

range_res=f1*c/(2*K);
range_axis=n*range_res;

vel_res=f2*lambda/2*2.237;   % 한칸당 velocity의 값 m/s
vel_axis=vel_res*(-P/2:P/2-1);

%% === 시각화 ===
figure(1);
imagesc(range_axis, vel_axis, rdm);  
% imagesc(rdm)
xlabel('Range (m)');
ylabel('Velocity (mi/h)');
title('Range-Doppler Map');
axis xy;
colorbar;

vmax=lambda*prf/4*2.237;
rmax=c*T_chirp/2;