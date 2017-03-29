import numpy as np
import random as rn

#Parameter Definition
light_speed=299792458
central_frequency = 2150e6
N_frequency=1

N_MBS = 100#MBS antenna number, 
N_SBS = 10 
N_Scatter = 10       
N_MS = 2000

K = 10 #Question, what's the use of this parameter?
central_lamda = light_speed/central_frequency
frequency_sample = central_frequency + np.linspace(-50e6, 50e6, N_frequency)

MBS_locations = np.zeros([N_MBS,3])
SBS_locations = np.zeros([N_SBS,3])   
Scatter_locations = np.zeros([N_Scatter,3])
MS_locations = np.zeros([N_MS,3])

H_MBS = np.zeros([N_MS,N_MBS,N_frequency])
H_SBS = np.zeros([N_MS,N_SBS,N_frequency])

for i in range(N_MBS):
	MBS_locations[i,:] =  [(i+1)*central_lamda/2,0,0] #since list is begin with 0 instead of 1
	
SBS_locations = [[-200,500,0],[200,500,0],[-500,200,0], [0,200,0], [500,200,0],[-200,-500,0],[200,-500,0],[-500,-200,0],[0,-200,0],[500,-200,0]]

for i in range(N_Scatter):
	while True:
		Scatter_locations[i,0] = 1400*(rn.random()-0.5)
		Scatter_locations[i,1] = 1400*(rn.random()-0.5)
		if(np.linalg.norm(Scatter_locations[i,:],2)<=700): 
			break
			
for i in range(N_MS):
	while True:
		MS_locations[i,0] = 1400*(rn.random()-0.5)
		MS_locations[i,1] = 1400*(rn.random()-0.5)
		if(np.linalg.norm(MS_locations[i,:],2)<=700): 
			break
	
for i_fre in range(N_frequency):
	opt={}
	opt['frequency'] = frequency_sample[i_fre]
    opt['K'] = K
    opt['lamda'] = light_speed/frequency_sample[i_fre]
	
	for i_MS in range(N_MS):
        for i_MBS in range(N_MBS):
            [H_MBS[i_MS,i_MBS,i_fre]] = h_cal(MS_locations[i_MS,:] , MBS_locations[i_MBS,:] , Scatter_locations,opt)
            for i_SBS in range(N_SBS):
               [H_SBS[i_MS,i_SBS,i_fre]] = h_cal(MS_locations[i_MS,:], SBS_locations[i_SBS,:] , Scatter_locations,opt)
