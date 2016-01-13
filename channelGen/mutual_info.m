load('2D_data_with_80_antennas_fixed2_SBSs_10_1_scatterers.mat');   % Load file
m = 8;
q = 10;
H_MBS_q = zeros(2000,m);
[COEFF, SCORE, LATENT] = pca(abs(H_MBS));  % Obtain new representation of H_MBS:SCORE
source = SCORE;
% source = abs(H_MBS);
for i = 1:m
    Maxi = max(source(:,i));
    Mini = min(source(:,i));
    H_MBS_q(:,i) = floor((source(:,i)-Mini)/(Maxi-Mini)*q*0.9999);
end
H_SBS_q = zeros(2000,1);
% Maxi = max(real(H_SBS(:,1)));
% Mini = min(real(H_SBS(:,1)));
% H_SBS_q(:) = floor((real(H_SBS(:,1))-Mini)/(Maxi-Mini)*q*0.9999);
[~,H_SBS_q] = max(abs(H_SBS),[],2); 

count_xy = zeros(q^m,q);
count_x = zeros(q^m,1);
count_y = zeros(q,1);
for i = 1:2000
    x = 1;
    for k = 1:m
        x = x+H_MBS_q(i,k)*q^(k-1);
    end
    count_x(x) = count_x(x)+1;
    y = H_SBS_q(i)+1;
    count_y(y) = count_y(y)+1;
    count_xy(x,y) = count_xy(x,y)+1;
end
I = 0;
for i = 1:q^m
    for j = 1:q
        if(count_xy(i,j)>0)
            I = I+count_xy(i,j)*log(count_xy(i,j)/count_x(i)/count_y(j))/(q^(m+1));
        end
    end
end
