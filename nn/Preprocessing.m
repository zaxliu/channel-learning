function [X,y] = Preprocessing(File)
% Preprocess GSCM Simulated Channel Response
    load(File);  % Load from dataset
    % X = [real(H_MBS),imag(H_MBS)];                  % Cat. real and imag parts as a long matrix
    X = abs(fft(H_MBS,[],2));
    [~,y] = max(abs(H_SBS),[],2);                   % Connect to the SBS with largest SNR
end