function [X,y] = Preprocessing(File)
% Preprocess GSCM Simulated Channel Response
load(File);  % Load from dataset

%% Different feature generation methods
% F = fft(H_MBS,[],2);
% X = abs(F);

% X = [abs(F),angle(F)];

% %  MS locations as input
% X = [MS_locations(:,1)/max(abs(MS_locations(:,1))),MS_locations(:,2)/max(abs(MS_locations(:,2)))];

F = fft(H_MBS,[],2);
Temp = log(abs(F));
cod = lloyds(Temp(:),20);
q = reshape(quantiz(Temp(:),cod),2000,200);
X = q;
X = (X-4.5)/4.5;

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
[~,y] = max(abs(H_SBS),[],2);                  % Connect to the SBS with largest SNR
end