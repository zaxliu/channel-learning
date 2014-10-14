M=40;%MBS antenna number
frequency=2.4e9;
lamda=3e8/frequency;
D=lamda*0.5;
H=zeros(1,M);
G=zeros(1,M);
for m=1:M
    d0=norm([x_MS,y_MS,z_MS]);
    H(m)=lamda/(4*pi*d0)*exp(j*2*pi*d0/lamda)*exp(-j*2*pi/lamda*(m-1)*D*z_MS/d0);
    for i=1:N_Scatter
        d=norm([x_MS-x_Scatter(i),y_MS-y_Scatter(i),z_MS-z_Scatter(i)])+norm([x_Scatter(i),y_Scatter(i),z_Scatter(i)]);
        G(m)=G(m)+lamda/(4*pi*d)*exp(j*2*pi*d/lamda)*exp(-j*2*pi/lamda*(m-1)*D*z_Scatter(i)/norm([x_Scatter(i),y_Scatter(i),z_Scatter(i)]));
    end
    H(m)=0.1*H(m)/abs(H(m))+0.9*G(m)/abs(G(m));
end
H_SBS=zeros(1,N_SBS);
for i_SBS=1:N_SBS
    d0=norm([x_MS-x_SBS(i_SBS),y_MS-y_SBS(i_SBS),z_MS-z_SBS(i_SBS)]);
    H_SBS(i_SBS)=lamda/(4*pi*d0)*exp(j*2*pi*d0/lamda);
    G_SBS=0;
    for i=1:N_Scatter
        d=norm([x_MS-x_Scatter(i),y_MS-y_Scatter(i),z_MS-z_Scatter(i)])+norm([x_Scatter(i)-x_SBS(i_SBS),y_Scatter(i)-y_SBS(i_SBS),z_Scatter(i)-z_SBS(i_SBS)]);
        G_SBS=G_SBS+lamda/(4*pi*d)*exp(j*2*pi*d/lamda);
    end
    H_SBS(i_SBS)=0.1*H_SBS(i_SBS)/abs(H_SBS(i_SBS))+0.9*G_SBS/abs(G_SBS);
end
figure(1);
subplot(1,2,1);plot(abs(H));title('amplitude');
subplot(1,2,2);plot(angle(H));title('phase');
figure(2);
subplot(1,2,1);plot(abs(H_SBS));title('amplitude');
subplot(1,2,2);plot(angle(H_SBS));title('phase');