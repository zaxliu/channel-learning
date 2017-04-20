import math 
import numpy as np

def h_cal(tx_loc, rx_loc, scat_loc, opt):
	K = opt[K]
	lamda = opt[lamda]
	num_scat = np.shape(scat_loc,1)
	d0 = np.linalg.norm(tx_loc-rx_loc,2)
	h_los = lamda/(4*math.pi*d0)*math.exp(1j*2*math.pi*d0/lamda)
	power_los = (lamda/(4*math.pi*d0))**2
	h_nlos = 0
	power_nlos = 0
	for i in range(num_scat):      
		d = np.linalg.norm(tx_loc- scat_loc[i,:]) + np.linalg.norm(scat_loc[i,:]-rx_loc)
		h_nlos = h_nlos + lamda/(4*math.pi*d)*math.exp(1j*2*pi*d/lamda)
		power_nlos = power_nlos + (lamda/(4*math.pi*d))**2
		
	power_los_adjust = K/(K+1)*(power_los + power_nlos)
	power_nlos_adjust = 1/(K+1)*(power_los + power_nlos)
	h = math.sqrt(power_los_adjust)*h_los/math.sqrt(power_los) + math.sqrt(power_nlos_adjust)*h_nlos/math.sqrt(power_nlos)

	return h
