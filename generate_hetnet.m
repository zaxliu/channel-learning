N_Scatter=40;
N_SBS=5;

r_MS=200+rand*500;
phi_MS=rand*2*pi;
x_MS=r_MS*cos(phi_MS);
y_MS=r_MS*sin(phi_MS);
z_MS=-10+20*rand;
x_SBS=zeros(1,N_SBS);
y_SBS=zeros(1,N_SBS);
z_SBS=zeros(1,N_SBS);

% r_Scatter=zeros(1,N_Scatter);
% phi_Scatter=zeros(1,N_Scatter);
x_Scatter=zeros(1,N_Scatter);
y_Scatter=zeros(1,N_Scatter);
z_Scatter=zeros(1,N_Scatter);
for i=1:N_Scatter
    r_Scatter=700*rand;
    phi_Scatter=rand*2*pi;
    z_Scatter(i)=-20+40*rand;
    x_Scatter(i)=x_MS+r_Scatter*cos(phi_Scatter);
    y_Scatter(i)=y_MS+r_Scatter*sin(phi_Scatter);
end
for i=1:N_SBS
    r_SBS=500*rand;
    phi_SBS=rand*2*pi;
    z_SBS(i)=-15+30*rand;
    x_SBS(i)=x_MS+r_SBS*cos(phi_SBS);
    y_SBS(i)=y_MS+r_SBS*sin(phi_SBS);
end

figure(1);

scatter3(x_Scatter,y_Scatter,z_Scatter,'b.');
hold on;
scatter3(x_SBS,y_SBS,z_SBS,'rs');
hold on;
plot3(x_MS,y_MS,z_MS,'rv');plot3(0,0,0,'rs','MarkerFaceColor','r');