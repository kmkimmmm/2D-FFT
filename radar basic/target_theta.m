% A matrix define
A=zeros(1,20);
for ii=1:20
    A(1,ii)=exp(sqrt(-1)*100*(ii-1));
end

%A matrix의 real 부분 추출(cos)
figure(1)
plot(1:length(A), real(A),'--x', 'MarkerSize',10,'MarkerEdgeColor','b')
xlabel('Time(s)')
ylabel('Real componet of the vector A')

N_fft=2^10;
A_fft=fft(A,N_fft);
f_s=1;

figure(2)
x_axis=(1:N_fft)*f_s*(1/N_fft);
y_axis=abs(A_fft);
plot(x_axis,y_axis);
xlabel('Frequency(Hz)')
ylabel('Magnitude of the FFT result');

[max_val, max_idx]=max(y_axis);

figure(3)
plot(1:length(A), real(A), '--x', 'MarkerSize', 10, 'MarkerEdgeColor','b')
hold on
X_axis2=1:20;
plot(X_axis2,cos(2*pi*x_axis(max_idx)*X_axis2),'-rd','MarkerSize','10','MarkerEdgeColor','r')
hold off
xlabel('Time(s)')

rad2deg(assin(x_axis(max_idx)))