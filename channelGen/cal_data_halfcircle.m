%%  Calculate Simulation Input Data
%   function calls: h_cal
%   output:     .mat file
%   time:      2015-12-01
%% version:  V3.1.3 
%©°©¸©´©¼©¤©¦©À©È©Ð©Ø©à
%=============================================================
% Changes:
%  ©Àget figures of sbs scatter ms
%  ©¸change sbs location&numbers
%=============================================================
% Todos:  
%  ©À try different sbs scatter and ms generate model
%  ©¸ further consider OFDM system

%% Parameter Definition
light_speed=299792458;
central_frequency = 2150e6;      %China Unicom 3g  downlink 2150MHz 2100~2200MHz
N_frequency=11;

N_MBS = 20;%MBS antenna number, 
N_SBS = 5; 
N_Scatter = 10;        
N_MS = 2000;   

K = 10;      % LOS factor, sqrt(K_Rician) = gamma/(1-gamma)
%% Initialization
central_lamda = light_speed/central_frequency;
frequency_sample = central_frequency + linspace(-50e6, 50e6, N_frequency);

MBS_locations = zeros(N_MBS,3);     
SBS_locations = zeros(N_SBS,3);     
Scatter_locations = zeros(N_Scatter,3);
MS_locations = zeros(N_MS,3);

H_MBS = zeros(N_MS,N_MBS,N_frequency);  % channel impulse responses of MBS
H_SBS = zeros(N_MS,N_SBS,N_frequency);  % channel impulse responses of SBS

%% Generate Locations
% in a 700m radius circle(2d)
    
    % GenerateMBS locations
    %linear arrangement start lovcation 0,0,0 gap=lamda/2
    for i = 1:N_MBS
            MBS_locations(i,:) =  [(i)*central_lamda/2,0,0];
    end
    
    % Generate SBS locations
    SBS_locations = [-200,500,0; 200,500,0;
                     -500,200,0; 0,200,0; 
                     500,200,0];
    
    % Generate scatterer location 
    for i = 1:N_Scatter
        while(1)
            Scatter_locations(i,:) = 1400*(rand-0.5);%x
            Scatter_locations(i,2) = 700*rand;%y
            %Scatter_locations(i,3) = 1400*(rand-0.5);%z
            if(norm(Scatter_locations(i,:))<=700)  
                break;
            end
        end
    end
    
    % generate MS location
    for i_MS = 1:N_MS
            while(1)        
                MS_locations(i_MS,1) = 1400*(rand-0.5);
                MS_locations(i_MS,2) = 700*rand;
                %MS_locations(i_MS,3) = 1400*(rand-0.5);
                if(norm(MS_locations(i_MS,:))<=700)  
                    break;
                end
            end
    end   
 %% figure
figure(1);
axis square;
rectangle('Position',[-700,-700,1400,1400],'Curvature',[1,1])
hold on;
plot(SBS_locations(:,1),SBS_locations(:,2),'r*');
plot(Scatter_locations(:,1),Scatter_locations(:,2),'ro');
plot(MS_locations(:,1),MS_locations(:,2),'.');
legend('SBS','Scatter','MS');
%% Calulate channel responses
for i_fre=1:N_frequency          
        opt.frequency = frequency_sample(i_fre);
        opt.K = K;
        opt.lamda = light_speed/frequency_sample(i_fre);
     
        % Calulate channel responses from different MS
        for i_MS = 1:N_MS
            % calculate responses of MBS antennas
            for i_MBS = 1:N_MBS
                [H_MBS(i_MS,i_MBS,i_fre)] = h_cal(MS_locations(i_MS,:) , MBS_locations(i_MBS,:) , Scatter_locations,opt);
            end
            % calculate responses of SBS antennas
            for i_SBS = 1:N_SBS
               [H_SBS(i_MS,i_SBS,i_fre)] = h_cal(MS_locations(i_MS,:) , SBS_locations(i_SBS,:) , Scatter_locations,opt); 
            end
        end

end
%% Figures 
        % % show amplitudes and phases of H_MBS(1,:) and H_SBS(1,:)
%         figure(2);
%         subplot(1,2,1);plot(abs(H_MBS(1,:,1)));title('amplitude');
%         subplot(1,2,2);plot(unwrap(angle(H_MBS(1,:,1))));title('phase');
%         figure(3);
%         subplot(1,2,1);plot(abs(H_SBS(1,:,1)));title('amplitude');
%         subplot(1,2,2);plot(unwrap(angle(H_SBS(1,:,1))));title('phase');
%% Data saving
        save(['2D_data_in_halfcircle_with_'...
            ,num2str(central_frequency/1e6),'+-50MHz_',num2str(N_frequency),'_samples_'...
            ,num2str(N_MBS),'_antennas_fixed_',num2str(N_SBS),'_SBSs_'...
            ,num2str(N_Scatter),'_scatterers_',num2str(N_MS),'_MSs.mat']...
            ,'N_frequency','N_MBS','N_SBS','N_Scatter','N_MS'...
            ,'MBS_locations','SBS_locations','Scatter_locations','MS_locations'...
            ,'H_MBS','H_SBS');
        
        
        
        