#installing MATLAB Engine for Python see https://cn.mathworks.com/help/matlab/matlab-engine-for-python.html
#matlab r2015b and python3.4

import matlab.engine
eng = matlab.engine.start_matlab()
  
#Parameter Definition
central_frequency = 2150e6 #China Unicom 3g  downlink 2150MHz 2100~2200MHz
N_frequency=11
N_MBS = 20
N_SBS = 5
N_Scatter = 10        
N_MS = 20
#call cal_data return 1 to show sucess
cal=eng.cal_data_halfcircle(central_frequency,N_frequency,N_MBS,N_SBS,N_Scatter,N_MS)
print(cal)