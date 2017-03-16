%Online algorithm for beam learning
%2017/3/13
%by Chen

%load workpath
addpath('../channelGen/');
%Parameters
light_speed=299792458;
central_frequency = 3500e6;      %3.5GHz parameters
edge_frequency = 3500e6;
N_frequency = 1;
N_MBS = 100;%MBS antenna number, 
N_SBS = 20; % single SBS with 20 antennas 
N_Scatter = 20; % Considering some scatters      
N_MS = 100000;  %Orignal map 
K = 10;      % LOS factor, sqrt(K_Rician) = gamma/(1-gamma)
Offline = 1; %1 generate offline data net, 0 use online orgirithm;
%Initiallization
central_lamda = light_speed/central_frequency;
edge_lamda = light_speed/edge_frequency;
frequency_sample = central_frequency + linspace(-50e6, 50e6, N_frequency);
edgefrequency_sample = edge_frequency + linspace(-50e6, 50e6, N_frequency);
MBS_locations = zeros(N_MBS,3);     
SBS_locations = zeros(N_SBS,3);     
Scatter_locations = zeros(N_Scatter,3);
MS_locations = zeros(N_MS,3);
H_MBS = zeros(N_MS,N_MBS,N_frequency);  % channel impulse responses of MBS
H_SBS = zeros(N_MS,N_SBS,N_frequency);  % channel impulse responses of SBS

if (Offline == 1)
%Locations of BSs and scatterers
% GenerateMBS locations
%linear arrangement start lovcation 0,0,5 gap=lamda/2
    for i = 1:N_MBS
            MBS_locations(i,:) =  [(i)*central_lamda/2,0,5];
    end
    
% Generate SBS locations
%linear arrangement start lovcation -200,500,5 gap=lamda/2
     for i = 1:N_SBS
             SBS_locations(i,:) =  [-200+(i)*central_lamda/2,500,5];
     end
    
    % Generate scatterer location 
    for i = 1:N_Scatter
        while(1)
            Scatter_locations(i,1) = 1400*(rand-0.5);%x
            Scatter_locations(i,2) = 1400*(rand-0.5);%y
            Scatter_locations(i,3) = 0.5+2*rand;%z
            if(norm(Scatter_locations(i,:))<=700)  
                break;
            end
        end
    end
    
    % generate MS location
    for i_MS = 1:N_MS
            while(1)        
                MS_locations(i_MS,1) = 1400*(rand-0.5);
                MS_locations(i_MS,2) = 1400*(rand-0.5);
                MS_locations(i_MS,3) = 0.5+2*rand;
                if(norm(MS_locations(i_MS,:))<=700&&norm(MS_locations(i_MS,:)-[-200,500,5])<=200&&norm(MS_locations(i_MS,:)-[-200,500,5])>=20)  
                    break;
                end
            end
    end   
 
%velocity of scatterers, considering 6 scatterers
Scatterer_velocity = 10*[1*rand+1,0.5*rand+0.5,0.5*rand,2*rand+2,2,1*rand];

%Calculate Initial Data Set
for i_fre=1:N_frequency          
        opt.frequency = frequency_sample(i_fre);
        opt.K = K;
        opt.lamda = light_speed/frequency_sample(i_fre);
        opt1 = opt;
        opt1.lamda = light_speed/edgefrequency_sample(i_fre);
        % Calulate channel responses from different MS
        
        for i_MS = 1:N_MS
            %Mobility of scatterers
            Scatter_locations(1:6,1) = Scatter_locations(1:6,1)+Scatterer_velocity'.*(2*rand(6,1)-1);
            Scatter_locations(1:6,2) = Scatter_locations(1:6,2)+Scatterer_velocity'.*(2*rand(6,1)-1);
            % calculate responses of MBS antennas
            for i_MBS = 1:N_MBS
                [H_MBS(i_MS,i_MBS,i_fre)] = h_cal(MS_locations(i_MS,:) , MBS_locations(i_MBS,:) , Scatter_locations,opt);
            end
            % calculate responses of SBS antennas
            for i_SBS = 1:N_SBS
               [H_SBS(i_MS,i_SBS,i_fre)] = h_cal(MS_locations(i_MS,:) , SBS_locations(i_SBS,:) , Scatter_locations,opt1); 
            end
        end

end


            
 %Prepocessing
 if (N_frequency==1)
 F = fft(H_MBS,[],2);
 else
 F = fft(H_MBS,[],2);%fre-anglef
 for i=1:N_MS
    f1=reshape(F(i,:,:),N_MBS,N_frequency);
    F(i,:,:)=fft(f1,[],2);
 end
 end
 X = log(abs(F())); 
 codebook_size = 20;
 codebook = lloyds(X(:),codebook_size);
 num_labels = 20; 
 X = reshape(quantiz(X(:), codebook), N_MS, N_MBS*N_frequency);
 center = (codebook_size-1)/2;
 X = (X-center) / center;
 %H_SBSr=reshape(H_SBS,N_MS*N_frequency,N_SBS);
 H_SBSr = H_SBS(:,:,round((N_frequency+1)/2));
 Y_SBS = H_SBSr*dftmtx(N_SBS);
 [~,y] = max(abs(Y_SBS),[],2);   
 target = zeros(N_MS,num_labels);
 for i = 1:N_MS
    target(i,y(i)) = 1;
 end
 x = X';
 t = target';
 %Training
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.
% Create a Pattern Recognition Network
hiddenLayerSize = [N_MBS*N_frequency,N_MBS];
net = patternnet(hiddenLayerSize);
% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
%net.input.processFcns = {'removeconstantrows','mapminmax'};
%net.output.processFcns = {'removeconstantrows','mapminmax'};
% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'crossentropy';  % Cross-Entropy
% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotconfusion', 'plotroc'};
% Train the Network
[net,tr] = train(net,x,t);
% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y);
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);
% Recalculate Training, Validation and Test Performance
trainTargets = t .* tr.trainMask{1};
valTargets = t .* tr.valMask{1};
testTargets = t .* tr.testMask{1};
trainPerformance = perform(net,trainTargets,y);
valPerformance = perform(net,valTargets,y);
testPerformance = perform(net,testTargets,y);
% Calculate Performance of beam
[dummy1,beam_slec_train] = max(y, [], 1);
[dummy2,beam_slec_cal] = max(target, [], 2);
beam_code = dftmtx(20);
% s = pi*linspace(0,1-1/M_Code,M_Code);
% beam_code = zeros(N_SBS,M_Code);
% for i = 1:M_Code
%     for jj=1:N_SBS
%         beam_code(jj,i)=exp(1j*pi*jj*cos(s(i)));
%     end
% end
beamAmp = abs(H_SBSr*beam_code);
beamPerformance = zeros(1,N_MS);
for i = 1:N_MS
    [dummy,index] = sort(y(:,i),'descend');
    beamPerformance(i) = beamAmp(i,beam_slec_train(i))/beamAmp(i,beam_slec_cal(i));
    %beamPerformance(i) = max([beamAmp(i,index(1)),beamAmp(i,index(2))])/beamAmp(i,beam_slec_cal(i));
    %beamPerformance(i) = max([beamAmp(i,index(1)),beamAmp(i,index(2)),beamAmp(i,index(3))])/beamAmp(i,beam_slec_cal(i));
end
cdfplot(beamPerformance);
trainbeamPerformance = beamPerformance.* tr.trainMask{1}(1,:);
valbeamPerformance = beamPerformance.* tr.valMask{1}(1,:);
testbeamPerformance = beamPerformance.* tr.testMask{1}(1,:);
plot_cdf(trainbeamPerformance,valbeamPerformance,testbeamPerformance);
N_SAMPLE = N_MS*N_frequency;
UserPerformance = [];
file = ['../data/OLdata_'...
            ,num2str(central_frequency/1e6),'+-50MHz_',num2str(N_frequency),'_samples_'...
            ,num2str(edge_frequency/1e6),'_tbs_'...
            ,num2str(N_MBS),'_antennas_fixed_',num2str(N_SBS),'_SBSs_'...
            ,num2str(N_Scatter),'_highspeed_scatterers_',num2str(N_SAMPLE),'_samples.mat'];
 save(file,'N_frequency','N_MBS','N_SBS','N_Scatter','N_MS'...
            ,'MBS_locations','SBS_locations','Scatter_locations','MS_locations'...
            ,'H_MBS','H_SBS','edge_frequency','Scatterer_velocity','x','t','net','y','beamPerformance','tr','num_labels','UserPerformance','codebook','N_SAMPLE');
else
  file = '../data/OLdata_3500+-50MHz_5_samples_3500_tbs_100_antennas_fixed_20_SBSs_20_scatterers_100000_samples';
  load(file); 
  frequency_sample = central_frequency + linspace(-50e6, 50e6, N_frequency);
  edgefrequency_sample = edge_frequency + linspace(-50e6, 50e6, N_frequency);
  net.trainParam.showWindow = false; 
  net.trainParam.showCommandLine = false; 
  codebook_size = 20;
  center = (codebook_size-1)/2;
  beamcode = dftmtx(N_SBS);
  MS_ADD = 2000;
  NMS_locations = zeros(MS_ADD,3);
  NH_MBS = zeros(MS_ADD,i_MBS,N_frequency);
  NH_SBS = zeros(MS_ADD,i_SBS,N_frequency);
  NUSER_Perform = zeros(1,MS_ADD*N_frequency);
  for jj = 1:MS_ADD;
      while(1)        
       NMS_locations(jj,1) = 1400*(rand-0.5);
       NMS_locations(jj,2) = 1400*(rand-0.5);
       NMS_locations(jj,3) = 0.5+2*rand;
          if(norm(NMS_locations(jj,:))<=700&&norm(NMS_locations(jj,:)-[-200,500,5])<=200&&norm(NMS_locations(jj,:)-[-200,500,5])>=20)  
               break;
           end
      end
      Scatter_locations(1:6,1) = Scatter_locations(1:6,1)+Scatterer_velocity'.*(2*rand(6,1)-1);
      Scatter_locations(1:6,2) = Scatter_locations(1:6,2)+Scatterer_velocity'.*(2*rand(6,1)-1);
      for i_fre=1:N_frequency          
        opt.frequency = frequency_sample(i_fre);
        opt.K = K;
        opt.lamda = light_speed/frequency_sample(i_fre);
        opt1 = opt;
        opt1.lamda = light_speed/edgefrequency_sample(i_fre);
        % Calulate channel responses from different MS
        % Mobility of scatterers
         % calculate responses of MBS antennas
            for i_MBS = 1:N_MBS
               NH_MBS(jj,i_MBS,i_fre) = h_cal(NMS_locations(jj,:) , MBS_locations(i_MBS,:) , Scatter_locations,opt);
            end
            % calculate responses of SBS antennas
            for i_SBS = 1:N_SBS
               NH_SBS(jj,i_SBS,i_fre) = h_cal(NMS_locations(jj,:) , SBS_locations(i_SBS,:) , Scatter_locations,opt1); 
            end            
      end
      HMBS_temp = NH_MBS(jj,:,:);
      HNBS_temp = NH_SBS(jj,:,:);
      if (N_frequency==1)
       F = fft(HMBS_temp,[],2);
      else
       F = fft(HMBS_temp,[],2);%fre-anglef
       f1=reshape(F(1,:,:),N_MBS,N_frequency);
       F(1,:,:)=fft(f1,[],2);
      end
       X_TEMP = log(abs(F())); 
       X_TEMP  = reshape(quantiz(X_TEMP(:), codebook), 1, N_MBS*N_frequency);
       X_TEMP = (X_TEMP-center) / center;
      %H_SBSr=reshape(H_SBS,N_MS*N_frequency,N_SBS);
       H_SBSr = HNBS_temp(:,:,round((N_frequency+1)/2));
       Y_TEMP= H_SBSr*beamcode;
      [~,y_temp] = max(abs(Y_TEMP),[],2);   
      t_temp = zeros(1,num_labels);
      t_temp(y_temp(1)) = 1;
      
      
     % Predict using exsiting network;
     perform_temp = net(X_TEMP');
     [~,y_out] = max(perform_temp,[],1);  
     beamAmp = abs(Y_TEMP);
     Beamperform_temp = zeros(1,N_frequency);
     for i = 1:1
      NUSER_Perform(N_frequency*(jj-1)+i) = beamAmp(i,y_out(i))/beamAmp(i,y_temp(i));
     end
     % Train the Network
     x = [x,X_TEMP'];
     t = [t,t_temp'];
     [net,tr] = train(net,x,t);
  end
  H_MBS = [H_MBS;NH_MBS];
  H_SBS = [H_SBS;NH_SBS];
  UserPerformance = [UserPerformance,NUSER_Perform];
  N_SAMPLE = N_SAMPLE + MS_ADD*N_frequency;
  MS_locations = [MS_locations;NMS_locations];
  AvgPerformance = zeros(1,MS_ADD);
  for jj = 1:MS_ADD
      AvgPerformance(jj) = mean(NUSER_Perform(1:jj));
  end
  figure; plot(AvgPerformance);xlabel('Number of users');ylabel('Average user performance');
  file = ['../data/OLdata_'...
            ,num2str(central_frequency/1e6),'+-50MHz_',num2str(N_frequency),'_samples_'...
            ,num2str(edge_frequency/1e6),'_tbs_'...
            ,num2str(N_MBS),'_antennas_fixed_',num2str(N_SBS),'_SBSs_'...
            ,num2str(N_Scatter),'_scatterers_',num2str(N_SAMPLE),'_samples.mat'];
  save(file,'N_frequency','N_MBS','N_SBS','N_Scatter','N_MS'...
            ,'MBS_locations','SBS_locations','Scatter_locations','MS_locations'...
            ,'H_MBS','H_SBS','edge_frequency','Scatterer_velocity','x','t','net','y','beamPerformance','tr','num_labels','UserPerformance','N_SAMPLE');
end
