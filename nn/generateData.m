load(strcat('../', config_file));

output_file = strcat('../channelGen/data/2D_data_in_halfcircle_with_'...
    ,num2str(central_frequency/1e6),'+-50MHz_',num2str(N_frequency),'_samples_'...
    ,num2str(N_MBS),'_antennas_fixed_',num2str(N_SBS),'_SBSs_'...
    ,num2str(N_Scatter),'_scatterers_',num2str(N_MS),'_MSs.mat');
load(output_file);

pkg load communications;

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

%% generate y
H_SBSr=reshape(H_SBS,N_MS*N_frequency,N_SBS);
[~,y] = max(abs(H_SBSr),[],2);                  % Connect to the SBS with largest SNR

save -6 data/X_file X;
save -6 data/y_file y;
