j=sqrt(-1);
antenna_num=6;
target_num=2;
noise_pw=0.1;
theta=[-10, 10];

alpha=[1;1];
Rss=[1 0;0 1];

%steering matix 만들기
mat_steer=zeros(antenna_num,size(theta,2));
for ii=1:size(theta,2)
    for jj=1:antenna_num
        mat_steer(jj,ii)=exp(j*pi*(jj-1)*sin(theta(ii)*pi/180));
    end
end

%Rxx 만들기
Rxx=mat_steer*Rss*mat_steer'+noise_pw*eye(antenna_num);


%의사 스펙트럼 만들기(Bartlett, Capon)
mat_alpha=zeros(antenna_num,1);
theta_start=-90;
theta_end=90;
theta_int=0.1;

P_Bartlett=zeros(1,(theta_end-theta_start)/theta_int+1);
P_Capon=zeros(1,(theta_end-theta_start)/theta_int+1);

mm=1;
for delta_theta=theta_start:theta_int:theta_end
    %일단 각 theta에 맞는 alpha matrix를 만들어보자
    for kk=1:antenna_num
        mat_alpha(kk,1)=exp(j*pi*(kk-1)*sin(delta_theta*pi/180));
    end
    P_Bartlett(1,mm)=(mat_alpha'*Rxx*mat_alpha)/(mat_alpha'*mat_alpha);
    P_Capon(1,mm)=1/(mat_alpha'*inv(Rxx)*mat_alpha);
    mm=mm+1;
end

%의사 스펙트럼 만들기(MUSIC)
[eigen_vec, eigen_val]=eig(Rxx);
eigen_vec_n=eigen_vec(:, 1:antenna_num-size(theta,2));
P_MUSIC=zeros(1,(theta_end-theta_start)/theta_int+1);

mm=1;
for delta_theta=theta_start:theta_int:theta_end
    for kk=1:antenna_num
        mat_alpha(kk,1)=exp(j*pi*(kk-1)*sin(delta_theta*pi/180));
    end
    P_MUSIC(1,mm)=(mat_alpha'*mat_alpha)/(mat_alpha'*eigen_vec_n*eigen_vec_n'*mat_alpha);
    mm=mm+1;
end

plot(theta_start:theta_int:theta_end, abs(P_Bartlett)/max(abs(P_Bartlett)),theta_start:theta_int:theta_end, abs(P_Capon)/max(abs(P_Capon)),...
    theta_start:theta_int:theta_end, abs(P_MUSIC)/max(abs(P_MUSIC)));   
xlabel('Angle (deg)')
ylabel('Normalized pseudospectrum')
axis([-30 30 0 1.2])
hold on
line([theta(1) theta(1)], [0 1.2], 'Color', 'b', 'LineStyle','--')
line([theta(2) theta(2)], [0 1.2], 'Color', 'b', 'Linestyle', '--')
hold of
grid on
legend('Bartlett','Capon','MUSIC','|theta_1','|theta2','FontSize',12 )

