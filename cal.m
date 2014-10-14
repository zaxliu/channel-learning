M=40;%MBS antenna number
frequency=2.4e9;
lamda=3e8/frequency;
D=lamda*0.5;
H=zeros(1,M);
G=zeros(1,M);
for m=1:M
    d0=norm([x_MS,y_MS,z_MS]);
    H(m)=lamda/(4*pi*d0)*exp(j*2*pi*d0/lamda)*exp(-j*2*pi/lamda*(m-1)*D*z_MS/d0);
    for i=1:N_MSscatter
        d=norm([x_MS-x_MSscatter(i),y_MS-y_MSscatter(i),z_MS-z_MSscatter(i)])+norm([x_MSscatter(i),y_MSscatter(i),z_MSscatter(i)]);
        G(m)=G(m)+lamda/(4*pi*d)*exp(j*2*pi*d/lamda)*exp(-j*2*pi/lamda*(m-1)*D*z_MSscatter(i)/norm([x_MSscatter(i),y_MSscatter(i),z_MSscatter(i)]));
    end
    H(m)=0.1*H(m)/abs(H(m))+0.9*G(m)/abs(G(m));
end
figure(1);
subplot(1,2,1);plot(abs(H));title('amplitude');
subplot(1,2,2);plot(angle(H));title('phase');
% figure(2);
% subplot(1,2,1);plot(abs(G));title('amplitude');
% subplot(1,2,2);plot(angle(G));title('phase');