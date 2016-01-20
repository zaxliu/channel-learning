File = '../channelGen/2D_data_in_halfcircle_with_2150+-50MHz_1_samples_20_antennas_fixed_5_SBSs_10_scatterers_2000_MSs.mat';
load(File);

%% initialization
m = 8;
q = 10;
H_MBS_q = zeros(2000,m);

%% spatial-domain PCA
[COEFF, SCORE, LATENT] = pca(abs(H_MBS));  % Obtain new representation of H_MBS:SCORE
source = SCORE;
upp = max(source, [], 1);
low = min(source, [], 1);
x = zeros(2000, 1);
for i = 1:m
    x = x + floor((source(:, i) - low(i))/(upp(i) - low(i))*q*0.9999)*q^(i-1);
end
[~, y] = max(abs(H_SBS),[],2);
disp(ent(y));
disp(ent(x));
disp(MI(x, y));
%% angular domain PCA
cd ../nn
[X,y] = Preprocessing(File);
cd ../info_theo
[COEFF, SCORE, LATENT] = pca(abs(X));  % Obtain new representation of H_MBS:SCORE
source = SCORE;
upp = max(source, [], 1);
low = min(source, [], 1);
x = zeros(2000, 1);
for i = 1:m
    x = x + floor((source(:, i) - low(i))/(upp(i) - low(i))*q*0.9999)*q^(i-1);
end
disp(ent(y));
disp(ent(x));
disp(MI(x, y));
