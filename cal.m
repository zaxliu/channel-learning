function [ h_los, h_nlos ] = cal( ms_location, ant_location, n_scatter, scatter_locations )
% Calculate channel impulse responses
%   ms_location, ant_location(1*3 size) is 3-D coodinate of ms, antenna. n_scatter
%   is the number of scatterers, scatter_locations(n_scatter size*3) is 3-D coodinates array
%   of scatterers

% basic configuration
frequency = 2.4e9;
lamda = 3e8/frequency;

% calculate h_los
d0 = norm(ms_location-ant_location); % distance of LOS
h_los = lamda/(4*pi*d0)*exp(1i*2*pi*d0/lamda);
% calculate h_nlos
h_nlos = 0;
for i = 1:n_scatter
    d = norm(ms_location- scatter_locations(i,:))+norm(scatter_locations(i,:)-ant_location);
    h_nlos = h_nlos+lamda/(4*pi*d)*exp(1i*2*pi*d/lamda);
end

end

