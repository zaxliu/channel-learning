import numpy as np
import random as rn
import cmath

def h_cal(tx_loc, rx_loc, scat_loc, opt):
	K = opt['K']
	lamda = opt['lamda']
	phase = opt['phase']
	num_scat = np.shape(scat_loc)[0]
	d0 = np.linalg.norm(tx_loc-rx_loc,2)
	h_los = lamda/(4*cmath.pi*d0)*cmath.exp(1j*2*cmath.pi*d0/lamda)
	power_los = (lamda/(4*cmath.pi*d0))**2
	h_nlos = 0
	power_nlos = 0
	for i in range(num_scat):      
		d = np.linalg.norm(tx_loc- scat_loc[i,:]) + np.linalg.norm(scat_loc[i,:]-rx_loc)
		h_nlos = h_nlos + lamda/(4*cmath.pi*d)*cmath.exp(1j*2*cmath.pi*(d/lamda+phase[i]))
		power_nlos = power_nlos + (lamda/(4*cmath.pi*d))**2	
	power_los_adjust = (power_los + power_nlos)/power_los*K/(K+1)
	power_nlos_adjust = (power_los + power_nlos)/power_nlos/(K+1)
	h = cmath.sqrt(power_los_adjust)*h_los + cmath.sqrt(power_nlos_adjust)*h_nlos
	return h

#Parameter Definition
light_speed=299792458
central_frequency = 2150e6
N_frequency=1 #add more points

N_MBS = 100 #MBS antenna number, 
N_SBS = 10 #number of SBSs
N_Scatter = 10 #number of scatters  
N_MS = 2000  #number of MSs

K = 10 #lician factor
central_lamda = light_speed/central_frequency
frequency_sample = central_frequency + np.linspace(-50e6, 50e6, N_frequency)

MBS_locations = np.zeros([N_MBS,3])
SBS_locations = np.zeros([N_SBS,3])   
Scatter_locations = np.zeros([N_Scatter,3])
MS_locations = np.zeros([N_MS,3])

H_MBS = np.zeros([N_MS,N_MBS,N_frequency],dtype=np.complex128)
H_SBS = np.zeros([N_MS,N_SBS,N_frequency],dtype=np.complex128)

for i in range(N_MBS):
	MBS_locations[i,:] =  [(i+1)*central_lamda/2,0,0] #since list is begin with 0 instead of 1

SBS_locations = [[-200,500,0],[200,500,0],[-500,200,0], [0,200,0], [500,200,0],[-200,-500,0],[200,-500,0],[-500,-200,0],[0,-200,0],[500,-200,0]]
SBS_locations=np.array(SBS_locations)

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
		opt['phase'] = np.random.random(size=N_Scatter)-0.5  #random phase shift due to scattering
		for i_MBS in range(N_MBS):
			H_MBS[i_MS][i_MBS][i_fre] = h_cal(MS_locations[i_MS,:] , MBS_locations[i_MBS,:] , Scatter_locations,opt)
		opt['phase'] = np.random.random(size=N_Scatter)-0.5
		for i_SBS in range(N_SBS):
			H_SBS[i_MS][i_SBS][i_fre] = h_cal(MS_locations[i_MS,:], SBS_locations[i_SBS,:] , Scatter_locations,opt)

np.savez(''.join(['./MS',str(N_MS),'_MBS',str(N_MBS),'_SBS',str(N_SBS),'_Fre',str(N_frequency),'_DataCL.npz']),N_frequency=N_frequency,N_MBS=N_MBS,\
	N_Scatter=N_Scatter,N_MS=N_MS,MBS_locations=MBS_locations,\
	SBS_locations=SBS_locations,Scatter_locations=Scatter_locations,\
	MS_locations=MS_locations,H_MBS=H_MBS,H_SBS=H_SBS,N_SBS=N_SBS)
