function [ h ] = h_cal( tx_loc, rx_loc, scat_loc, opt)
% Calculate Channel Impulse Response
% This function calculate the complex channel impulse responce between a
% pair of antennas. Single scattering is also allowed, with scattering
% power rescaled based on user specified Rician factor.
%   Input:
%       tx_loc: location of tx antennas, 1 by 3 matrix
%       rx_loc: location of rx antennas, 1 by 3 matrix
%       scat_loc: location of scatters, num_scat by 3 matrix
%       opt: options
%           opt.frequency: carrier frequency in Hz, scalar, >0
%           opt.K: Rician factor, scalar, >0
%   Output:
%       h: complex channel responce
%% Initialization
frequency = opt.frequency;
K = opt.K;
lamda = 3e8/frequency;
num_scat = size(scat_loc,1);
%% Calculate LOS
d0 = norm(tx_loc-rx_loc);                       % length of LOS path
h_los = lamda/(4*pi*d0)*exp(1i*2*pi*d0/lamda);  % LOS channel responce
power_los = (lamda/(4*pi*d0))^2;                % LOS power
%% Calculate non-LOS
h_nlos = 0;
power_nlos = 0;
for i = 1:num_scat
% for each scatterer
    d = norm(tx_loc- scat_loc(i,:)) + norm(scat_loc(i,:)-rx_loc); % length of non-LOS path
    h_nlos = h_nlos + lamda/(4*pi*d)*exp(1i*2*pi*d/lamda);        % accumulate nLOS path response
    power_nlos = power_nlos + (lamda/(4*pi*d))^2;                 % accumulate nLOS path power
end
%% Path power scaling
power_los_adjust = K/(K+1)*(power_los + power_nlos);
power_nlos_adjust = 1/(K+1)*(power_los + power_nlos);
h = sqrt(power_los_adjust)*h_los/sqrt(power_los) + sqrt(power_nlos_adjust)*h_nlos/sqrt(power_nlos);
% h = h_los;    % return LOS component only
end

