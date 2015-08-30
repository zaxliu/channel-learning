%%计算信道响应数据样本
%调用函数 h_cal
%输出数据 .mat文件，文件名见最后输出
%时间：    2015年8月30日21:08:19
%作者：    李罡
%% 版本：  V2.1
%-Change
%---更改为三维空间，mbs，sbs位置不变，scatter，ms分布改为三维
%---更改散射体生成方式
%---更改范围至边长1400米，中心与原点正方体内。
%---注释掉ms生成范围限制     探讨？是否可行
%-Todo in next version
%--使用新数组储存MBS位置

%% Definition of parameters
light_speed=299792458;
N_Scatter = 10;     %散射体个数
N_SBS = 5;      %？
N_MS = 20;    % MS number  Mobile Station 终端
M = 10; %MBS antenna number 天线数,天线坐标从0，0开始间隔lamda/2

SBS_locations = zeros(N_SBS,3);     %储存xyz坐标
Scatter_locations = zeros(N_Scatter,3);
MS_locations = zeros(N_MS,3);
K = 10;      % LOS factor, sqrt(K_Rician) = gamma/(1-gamma)     
                % Line of sight视距径？ K_Rician 瑞森衰弱因子？

frequency = 2100e6;      %初始频率取联通3g，1950MHz上行，2150MHz下行
for fre_number=0:1          %!!为便于调试仅产生一组
        frequency=frequency+10e6;       %对不同频率计算
        opt.frequency = frequency;
        opt.K = K;
        lamda = light_speed/frequency;
        opt.lamda = lamda;
        D = lamda*0.5;  % distance between antenna elements of MBS

        H_MBS = zeros(N_MS,M);  % channel impulse responses of MBS，第n个ms对第m根天线

        H_SBS = zeros(N_MS,N_SBS);  % channel impulse responses of SBS

        %% Generate scatterer location 随机产生散射体位置
                %边长1400米，中心于原点正方体内。
        for i = 1:N_Scatter
            r_Scatter = 700*rand;   %半径
            phi_Scatter = rand*pi;  %俯角
            Scatter_locations(i,1) = 1400*(rand-0.5);%x坐标
            Scatter_locations(i,2) = 1400*(rand-0.5);%y
            Scatter_locations(i,3) = 1400*(rand-0.5);%z
            
        end

        %% Generate SBS locations
        SBS_locations = [-200,500,0;200,500,0;-500,200,0;0,200,0;500,200,0];
        % % generate random locations
        % for i = 1:N_SBS
        %     r_SBS = 500*rand;
        %     phi_SBS = pi*rand;
        %     SBS_locations(i,1) = r_SBS*cos(phi_SBS);
        %     SBS_locations(i,2) = r_SBS*sin(phi_SBS);
        % end
        %% Calulate channel responses from different MS
        for i_MS = 1:N_MS
            while(1)        %产生单个ms 位置
                MS_locations(i_MS,1) = 1400*(rand-0.5);
                MS_locations(i_MS,2) = 1400*(rand-0.5);
                MS_locations(i_MS,3) = 1400*(rand-0.5);
                break;
        %                 if(norm(MS_locations(i_MS,:))<=700)  不加入范围限制是否可以？
        %                     break;
        %                 end
            end
            % calculate responses of MBS antennas
            %H1 = zeros(M,1);%?似乎没用
            %H2 = zeros(M,1);
            for m = 1:M
                [H_MBS(i_MS,m)] = h_cal(MS_locations(i_MS,:) , [(m-1)*D,0,0] , Scatter_locations,opt);
            end
            % calculate responses of SBS antennas
            for i_SBS = 1:N_SBS
               [H_SBS(i_MS,i_SBS)] = h_cal(MS_locations(i_MS,:) , SBS_locations(i_SBS,:) , Scatter_locations,opt); 
            end
        end
        %% Figures
        % figure(1);
        % scatter3(Scatter_locations(:,1),Scatter_locations(:,2),Scatter_locations(:,3),'b.');
        % hold on;
        % scatter3(SBS_locations(:,1),SBS_locations(:,2),SBS_locations(:,3),'rs');
        % hold on;
        % plot3(MS_locations(:,1),MS_locations(:,2),MS_locations(:,3),'rv');
        % plot3(0,0,0,'rs','MarkerFaceColor','r');
        % hold off;
        % % show amplitudes and phases of H_MBS(1,:) and H_SBS(1,:)
        % figure(2);
        % subplot(1,2,1);plot(abs(H_MBS(1,:)));title('amplitude');
        % subplot(1,2,2);plot(unwrap(angle(H_MBS(1,:))));title('phase');
        % figure(3);
        % subplot(1,2,1);plot(abs(H_SBS(1,:)));title('amplitude');
        % subplot(1,2,2);plot(unwrap(angle(H_SBS(1,:))));title('phase');
        %% Data saving
        save(['2D_data_with_',num2str(frequency/1e6),'MHz'...
            ,num2str(M),'_antennas_fixed2_SBSs_',num2str(N_Scatter),'_scatterers.mat']...
            ,'frequency','N_Scatter','N_SBS','N_MS','SBS_locations','Scatter_locations','MS_locations','H_MBS','H_SBS');

end
