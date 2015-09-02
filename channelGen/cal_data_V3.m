%%  calculate chanel response
%   function    h_cal
%   file save     .mat file
%   time:      2015-09-02
%% version:  V3.0
%   rearrange code
%-Change
%---separate location generator and channel respond
%-Todo in next version
%---put different frequency in H_MBS~~

%% Definition of parameters
light_speed=299792458;
central_frequency = 2150e6;      %China Unicom 3g  downlink 2150MHz 2100~2200MHz
central_lamda = light_speed/central_frequency;
N_frequency=11;

N_MBS = 10;%MBS antenna number, 
N_SBS = 5; 
N_Scatter = 10;        
N_MS = 20;   
K = 10;      % LOS factor, sqrt(K_Rician) = gamma/(1-gamma)     

MBS_locations = zeros(N_MBS,3);     
SBS_locations = zeros(N_SBS,3);     
Scatter_locations = zeros(N_Scatter,3);
MS_locations = zeros(N_MS,3);

H_MBS = zeros(N_MS,M);  % channel impulse responses of MBS
H_SBS = zeros(N_MS,N_SBS);  % channel impulse responses of SBS

%% generate locations
    % in a 700m radius circle(2d)
    %% GenerateMBS locations
     %linear arrangement start lovcation 0,0,0 gap=lamda/2
    for i = 1:N_MBS
            MBS_locations(i,:) =  [(i)*central_lamda/2,0,0];
    end
    
    %% Generate SBS locations
    SBS_locations = [-200,500,0;200,500,0;-500,200,0;0,200,0;500,200,0];
    
    %% Generate scatterer location 
    for i = 1:N_Scatter
        while(1)
            Scatter_locations(i,:) = 1400*(rand-0.5);%x
            Scatter_locations(i,2) = 1400*(rand-0.5);%y
            %Scatter_locations(i,3) = 1400*(rand-0.5);%z
            if(norm(Scatter_locations(i,:))<=700)  
                break;
            end
        end
    end

    %% generate MS location
    for i_MS = 1:N_MS
            while(1)        
                MS_locations(i_MS,1) = 1400*(rand-0.5);
                MS_locations(i_MS,2) = 1400*(rand-0.5);
                %MS_locations(i_MS,3) = 1400*(rand-0.5);
                if(norm(MS_locations(i_MS,:))<=700)  
                    break;
                end
            end
    end
    
%% Calulate channel responses

frequency_sample = central_frequency + linspace(-50e6, 50e6, N_frequency);
for fre_this=frequency_sample          
        opt.frequency = fre_this;
        opt.K = K;
        opt.lamda = light_speed/fre_this;
     
        %% Calulate channel responses from different MS
        for i_MS = 1:N_MS
            % calculate responses of MBS antennas
            for i_MBS = 1:N_MBS
                [H_MBS(i_MS,i_MBS)] = h_cal(MS_locations(i_MS,:) , MBS_locations(i_MBS,:) , Scatter_locations,opt);
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
        save(['2D_data_with_',num2str(fre_this/1e6),'MHz_'...
            ,num2str(N_MBS),'_antennas_fixed2_SBSs_',num2str(N_Scatter),'_scatterers.mat']...
            ,'fre_this','N_Scatter','N_SBS','N_MS','SBS_locations','Scatter_locations','MS_locations','H_MBS','H_SBS');

end
