% 파라미터 설정
fc=1e9; %송신 신호 주파수
fd=1e3; %도플러 효과 주파수
Ts=30*10^-12; %샘플링 주기
fs=1/Ts; %샘플링 주파수
n=1:1:1900; %샘플링 개수
c=3*10^8; %전파의 속도
distance=c*n*Ts/2; %거리 계산

% 구간 0: 노이즈
noise_signal0 = sin(2*pi*10*n(1:100)) + 1.5e2*rand(1, 100);

% 구간 1: 송신 신호
transmission_signal = 1.5*10^4*exp(-10*n(101:500)) .* cos(2*pi*fc*n(101:500))+ 1.5e4*0.1*rand(1, 400);

% 구간 2: 노이즈
noise_signal1 = sin(2*pi*10*n(501:600)) + 1.5e2*rand(1, 100);

% 구간 3: 커플링
coupling_signal =  1.5*10^4*0.8*exp(-10*n(601:1000)) .* cos(2*pi*fc*n(601:1000)) +1.5e4*0.1*rand(1, 400);

% 구간 4: 노이즈
noise_signal2 = sin(2*pi*10*n(1001:1100)) + 1.5e2*rand(1, 100);

% 구간 5: 타겟
target_signal = 1.5e4*0.7*exp(-10*n(1101:1500)) .* cos(2*pi*(fc+fd)*n(1101:1500))+ 1.5e4*0.1*rand(1, 400);

% 구간 6: 노이즈
noise_signal3 = sin(2*pi*10*n(1501:1900)) + 1.5e2*rand(1, 400);


% 모든 구간을 합치기
signal = [noise_signal0, transmission_signal, noise_signal1, ...
          coupling_signal, noise_signal2, target_signal, noise_signal3];

% 파형 그리기
figure(1);
plot(n, signal);
%axis([0 2000 -2e4 2e4])
xlabel('Sample');
ylabel('Magnitude');
title('파형 시뮬레이션');
grid on;


%거리 축 환산
figure(2);
plot(distance,signal);
%axis([0 10 -2e4 2e4])
xlabel('distance[m]');
ylabel('Magnitude');
title('거리 축 환산 그래프');
grid on;

%상관기를 통한 거리 검출
[r,tau]=xcorr(signal, transmission_signal);
figure(3);

plot(tau,r);
%axis([-500 2000 -2*10^9 10e9 ])
grid on;







