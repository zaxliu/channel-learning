function [X,y] = Preprocessing(File)
% Preprocess GSCM Simulated Channel Response
%% version:  V3.0.0 
%©°©¸©´©¼©¤©¦©À©È©Ð©Ø©à
%=============================================================
% Changes:
%  ©¸reshape input 
%=============================================================
% Todos:  

% File = '../channelGen/2D_data_with_2150+-50MHz_11_samples_20_antennas_fixed_10_SBSs_10_scatterers_2000_MSs.mat';
load(File);  % Load from dataset

%% Generate feature X
% % ============ Domain conversion ==============
% % Option 1: angular-domain responce
% % Note: if H_MBS contain frequency domain responce, will give
% % angular-domain responce at different freqencies.
F = fft(H_MBS,[],2);

% % Option 2: MS locations
% X = [MS_locations(:,1)/max(abs(MS_locations(:,1))),MS_locations(:,2)/max(abs(MS_locations(:,2)))];

% % Option 3: angular-temporal-domain amplitude
% % Method 3.1: manually do fft() twice
% F = fft(H_MBS,[],2);%fre-anglef
% for i=1:N_MS
%     f1=reshape(F(i,:,:),N_MBS,N_frequency);
%     F(i,:,:)=fft(f1,[],2);
% end
% Method 3.2: manually do fft() twice
% F = fft(fft(H_MBS, [], 2), [], 3);

% % =========== Extract real from complex scalar =============
% X = abs(F);  % amplitude
% X = [abs(F),angle(F)];  % amplitude/phase stack
X = abs(F());  % single frequency

% % =========== Continuous non-linear transformation ==========
X = log(X);      % log(x)
% X = log(1 + X);  % log(1+x)

% % =========== Discrete non linear transformation ========
codebook_size = 20;
codebook = lloyds(X(:),codebook_size);
X = reshape(quantiz(X(:), codebook), N_MS, N_MBS*N_frequency);

% % ========== Standarization ===============
center = (codebook_size-1)/2;
X = (X-center) / center;

% ==========================================
% ========== Sketch code below ==============
% % quantiz for MS_locations
% N = 5;
% [px,~] = lloyds(MS_locations(:,1),2^N);
% [py,~] = lloyds(MS_locations(:,2),2^N);
% index_x = quantiz(MS_locations(:,1),px);
% index_y = quantiz(MS_locations(:,2),py);
% sx = dec2bin(index_x,N);
% sy = dec2bin(index_y,N);
% X = zeros(size(MS_locations,1),2*N);
% for i = 1:N
%     X(:,i) = str2num(sx(:,i));
%     X(:,i+N) = str2num(sy(:,i));
% end
    % 2*2^N length
% X = zeros(size(MS_locations,1),2*(2^N));
% for i = 1:size(MS_locations,1)
%     X(i,index_x(i)+1)=1;
%     X(i,index_y(i)+N+1)=1;
% end

%% generate y
H_SBSr=reshape(H_SBS,N_MS*N_frequency,N_SBS);
[~,y] = max(abs(H_SBSr),[],2);                  % Connect to the SBS with largest SNR
end