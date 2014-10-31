cal.m——计算冲击响应的函数
	
cal_data.m——合并了原来的generate_data.m

data_with_Xantennas.mat——X表示Macro BS天线数目
	N_Scatter:散射体数目
	N_SBS:Small BS数目
	SBS_locations：Small BS三维坐标数组
	Scatter_locations：散射体三维坐标数组
	N_MS:MS数目，目前是8000
	MS_locations：MS三维坐标数组
	H_MBS(i_MS,m)：计算得到的第i_MS个MS在MBS的第m根天线上的信道冲击响应
	H_SBS(i_MS,i_SBS)：计算得到的第i_MS个MS在第i_SBS个SBS上的信道冲击响应