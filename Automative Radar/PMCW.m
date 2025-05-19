%% 파라미터 설정 
fc = 77e9;          % 중심 주파수 (Hz)
Tc = 2e-9;          % chip duration
M = 256;            % 칩 개수
L = 256;            % 시퀀스 개수
c = 3e8;            % 빛의 속도 (m/s)

range_resolution = 0.3;
velocity_resolution = 0.94;

target_range = 20;    % 타겟 거리 (m)
target_velocity = 12; % 타겟 속도 (m/s)
delay_index = round(2 * target_range / (c * Tc));
doppler_frequency = 2 * fc * target_velocity / c;

%% PN 시퀀스 생성

pn_generator = comm.PNSequence( ...
    'Polynomial',[6 1 0], ...
    'InitialConditions',[1 0 1 1 0 1 ], ...
    'Mask',[1 1 0 1 0 1], ...
    'SamplesPerFrame',M);

chip_sequence = step(pn_generator);
chip_sequence = 2 * chip_sequence - 1;

%% receive signal
m = 0:M-1;
l = 0:L-1;

% mm은 열, ll은 행
[mm, ll] = meshgrid(m, l);

% delay
chip_indices = mm - delay_index;
valid_chip_mask = (chip_indices >= 0) & (chip_indices < M);

% 해당 인덱스의 칩 시퀀스 값 가져오기 (유효하지 않은 인덱스는 0)
new_c = zeros(size(chip_indices));
new_c(valid_chip_mask) = chip_sequence(chip_indices(valid_chip_mask) + 1);

% 위상 항 계산
phase = 2 * pi * doppler_frequency * M * Tc * ll;

% 수신 신호 값 계산
x = new_c .* exp(1j * phase);

%% test

% % test sequence -> 첫 번째 값만 1인 1x256의 array
% test_sequence=zeros(1,256);
% test_sequence(1)=1;
% 
% % delay
% test_indices=mm-delay_index;
% test_valid_chip_mask = (test_indices >= 0) & (test_indices < M);
% 
% test_new_c = zeros(size(test_indices));
% test_new_c(valid_chip_mask) = test_sequence(test_indices(test_valid_chip_mask) + 1);
%% 신호처리

% correlation
matchedf_out = zeros(length(l), 2*(length(m))-1);
for l = 1:L
    matchedf_out(l,:) = xcorr(conj(x(l,:)), chip_sequence);
end

% fft 
rd_map = fftshift(fft(matchedf_out,[], 1), 1);
rd_map_abs = abs(rd_map);

% 거리, 속도 axis
max_range = range_resolution * (2*M - 1) / 2; 
range_axis_compressed = -max_range:range_resolution:max_range-range_resolution; 

max_velocity = velocity_resolution * L / 2;
velocity_axis = -max_velocity:velocity_resolution:max_velocity-velocity_resolution;

%% 3D RD 맵 플롯
figure(1);
surf(velocity_axis, range_axis_compressed(M:end), abs(rd_map_abs(:,M:end))'); 
colorbar;
title('3D Range-Doppler Map (with Chip Sequence)');
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Magnitude');
view(135, 45);
grid on;

%% 실제 타겟 위치
hold on;
plot3(target_velocity, target_range, max(abs(rd_map_abs(:))), 'r.', 'MarkerSize', 20);
hold off;

%% simulation 최대값 

% 최대값 찾기
[max_val, max_idx] = max(abs(rd_map_abs(:)));
[max_row, max_col] = ind2sub(size(rd_map_abs), max_idx);

% 거리, 속도 찾기
max_range_index_compressed = max_col - M + 1; 
max_velocity_index = max_row;
estimated_range = range_axis_compressed(max_range_index_compressed + M -1); 
estimated_velocity = velocity_axis(max_velocity_index);

% plot
hold on;
plot3(estimated_velocity, estimated_range, max_val, 'g*', 'MarkerSize', 10); 
hold off;

