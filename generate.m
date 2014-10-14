N_MSscatter=12;
N_MBSscatter=4;
r_MBSscatter=zeros(1,N_MBSscatter);
phi_MBSscatter=zeros(1,N_MBSscatter);
x_MBSscatter=zeros(1,N_MBSscatter);
y_MBSscatter=zeros(1,N_MBSscatter);
z_MBSscatter=zeros(1,N_MBSscatter);
for i=1:N_MBSscatter
    r_MBSscatter(i)=100*randn;
    phi_MBSscatter(i)=rand*2*pi;
    z_MBSscatter(i)=rand*10-5;
    x_MBSscatter(i)=r_MBSscatter(i)*cos(phi_MBSscatter(i));
    y_MBSscatter(i)=r_MBSscatter(i)*sin(phi_MBSscatter(i));
end

r_MS=200+rand*500;
phi_MS=rand*2*pi;
x_MS=r_MS*cos(phi_MS);
y_MS=r_MS*sin(phi_MS);
z_MS=-10+20*rand;
r_MSscatter=zeros(1,N_MSscatter);
phi_MSscatter=zeros(1,N_MSscatter);
x_MSscatter=zeros(1,N_MSscatter);
y_MSscatter=zeros(1,N_MSscatter);
z_MSscatter=zeros(1,N_MSscatter);
for i=1:N_MSscatter
    r_MSscatter(i)=100*randn;
    phi_MSscatter(i)=rand*2*pi;
    z_MSscatter(i)=z_MS+rand*10-5;
    x_MSscatter(i)=x_MS+r_MSscatter(i)*cos(phi_MSscatter(i));
    y_MSscatter(i)=y_MS+r_MSscatter(i)*sin(phi_MSscatter(i));
end
figure(1);
scatter3(x_MBSscatter,y_MBSscatter,z_MBSscatter,'r');
hold on;
plot3(0,0,0,'r*');
scatter3(x_MSscatter,y_MSscatter,z_MSscatter,'b');
hold on;
plot3(x_MS,y_MS,z_MS,'b*');