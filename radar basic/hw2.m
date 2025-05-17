j=sqrt(-1);
antenna_num=8;
data_num=1000;
target_num=2;

%matrix X만들기->-90에서 90까지의 난수
mat_x=-90+180*rand(antenna_num,data_num);

%Rxx 만들기
acc_mat=zeros(8,8);

for ii=1:data_num
    column_vec=mat_x(:,ii);
    product_mat=column_vec*column_vec';
    acc_mat=acc_mat+product_mat;
end

Rxx=acc_mat/data_num;

%의사 스펙트럼 만들기
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
eigen_vec_n=eigen_vec(:, 1:antenna_num-target_num);
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
axis([-90 90 0 1.2])
grid on
legend('Bartlett','Capon','MUSIC','FontSize',12 )



    


