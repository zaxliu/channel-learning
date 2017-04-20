项目说明
----
root  
>channelGen
>>cal_data_2D.m: （主程序）生成散射体、SBS、MS位置，计算信道冲击响应并存储  
h_cal.m: 计算冲击响应的函数  

>nn
>>nnCE.m：（主程序）基于神经网络进行SBS接入预测  
Preprocessing.m：对信道冲击响应进行预处理，生成NN输入  
sigmoidGradient.m  
sigmoid.m  
randInitializeWeight.m  
predict.m  
nnCostFunction.m  
fmincg
