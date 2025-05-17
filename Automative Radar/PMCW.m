%% 파라미터 설정 (이전 코드와 동일)
fc = 77e9;          % 중심 주파수 (Hz)
Tc = 2e-9;          % 칩 간격 (s)
M = 256;            % 칩 개수
L = 256;            % 시퀀스 개수
c = 3e8;      % 빛의 속도 (m/s)

range_resolution = 0.3;
velocity_resolution = 0.94;

target_range = 20;    % 타겟 거리 (m)
target_velocity = 12; % 타겟 속도 (m/s)
delay_index = round(2 * target_range / (c * Tc));
doppler_frequency = 2 * fc * target_velocity / c;

%% PN 시퀀스 생성

% PN 시퀀스 생성 객체 생성
pn_generator = comm.PNSequence( ...
    'Polynomial',[6 1 0], ...
    'InitialConditions',[0 0 0 0 0 1], ...
    'Mask',[1 1 0 1 0 1], ...
    'SamplesPerFrame',M);

% PN 시퀀스 생성
chip_sequence = step(pn_generator);

% +- 1로 변환
chip_sequence = 2 * chip_sequence - 1;

%% receive signal
m = 0:M-1;
l = 0:L-1;
x=zeros(length(l),length(m));

% received signal
for i_l = 1:L
    for i_m = 1:M
        % 칩 시퀀스 인덱스 계산 (지연 고려)
        chip_index = i_m - 1 -delay_index;
        if chip_index >= 0 && chip_index < M
            c_val = chip_sequence(chip_index + 1);
        else
            c_val = 0; % 지연 범위를 벗어난 경우 0으로 처리 
        end

        % 위상 항 계산
        phase = 2 * pi * (doppler_frequency * M * Tc * l(i_l) + doppler_frequency * Tc * m(i_m));

        % 수신 신호 값 계산
        x(i_l, i_m) =  c_val * exp(1j * phase);
    end
end

%% replica sequence (수신 신호 처리 시 사용)
replica_sequence = conj(chip_sequence); 

% correlation
range_compressed_signal = zeros(length(l), 2*(length(m))-1);
% 시퀀스 하나에 대해서 convolution 실행 
for l = 1:L
    range_compressed_signal(l,:) = conv(received_signal(l,:), replica_sequence);
end

% 도플러 처리 
rd_map = fftshift(fft(range_compressed_signal, [], 1), 1);
rd_map_abs = abs(rd_map);

% 거리 및 속도 축 생성 (거리 축은 컨볼루션 길이만큼 늘어남)
max_range = range_resolution * (2*M - 1) / 2; % 대략적인 최대 거리
range_axis_compressed = -max_range:range_resolution:max_range-range_resolution; % 수정된 거리 축


max_velocity = velocity_resolution * L / 2;
velocity_axis = -max_velocity:velocity_resolution:max_velocity-velocity_resolution;

%% 3D RD 맵 플롯
figure(1);
surf(velocity_axis, range_axis_compressed(M:end), abs(rd_map_abs(:, M:end))'); % 플롯 범위 조정
colorbar;
title('3D Range-Doppler Map (with Chip Sequence)');
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Magnitude');
view(135, 30);
grid on;

% 이론적인 타겟 위치 표시
hold on;
plot3(target_velocity, target_range, max(abs(rd_map_abs(:))), 'r.', 'MarkerSize', 20);
hold off;

