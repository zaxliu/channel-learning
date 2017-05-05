import tensorflow as tf 
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.cluster import KMeans
from sklearn.utils import shuffle
from sklearn import preprocessing
# First, read data from file and preprocess and other functions.
def Preprocess(FileName):
	Data = np.load(FileName)
	H_MBS=Data['H_MBS']
	H_SBS=Data['H_SBS']
	N_MS=Data['N_MS']
	N_MBS=Data['N_MBS']
	N_SBS=Data['N_SBS']
	N_frequency=Data['N_frequency']
	F=np.fft.fft(H_MBS,axis=1)
	X=np.log(np.abs(F))
	X=X.reshape(N_MS,N_MBS*N_frequency)
	min_max_scaler = preprocessing.MinMaxScaler()#Scaler X to [0,1], can be replaced by Lloyds
	X = min_max_scaler.fit_transform(X)
	#Temp=X.flatten()
	#k_means or Lloyd
	#Temp_sample = shuffle(Temp, random_state=0)[:3000]
	#Temp_sample=Temp_sample.reshape(-1,1)
	#kmeans=KMeans(n_clusters=20, random_state=0).fit(Temp_sample)
	#Temp=Temp.reshape(-1,1)
	#Temp = kmeans.predict(Temp)
	#X=Temp.reshape(N_MS,N_MBS*N_frequency)
	#H_SBSr=np.reshape(H_SBS,N_MS*N_frequency,N_SBS)
	H_SBSr=np.reshape(H_SBS,(N_MS*N_frequency,N_SBS))
	#H_SBSr and H_SBS are identical, so why should we add this line?
	y=np.argmax(np.abs(H_SBS),axis=1)
	Y_temp=np.zeros((np.shape(y)[0],N_SBS))
	for i in range(np.shape(y)[0]):
		Y_temp[i][y[i]]=1
	y=Y_temp
	return (X,y)

def add_layer(inputs, in_size, out_size, activation_function=None):
    # add one more layer and return the output of this layer
    Weights = tf.Variable(tf.random_normal([in_size, out_size]))
    biases = tf.Variable(tf.random_normal([out_size]) + 0.1)
    Wx_plus_b = tf.matmul(inputs, Weights) + biases
    #regularizer = tf.nn.l2_loss(Weights)+tf.nn.l2_loss(biases)
    regularizer = tf.nn.l2_loss(Weights)
    if activation_function is None:
        outputs = Wx_plus_b
    else: 
        outputs = activation_function(Wx_plus_b)
    return outputs, regularizer

# Second, divide the dataset into Train and Test set
X,y=Preprocess('MS2000_MBS100_SBS10_Fre1_DataCL.npz')#X: 2000*100, y:2000*1np.savetxt("/home/xgwx/data/H_X.txt",H_MBS)
X_train, X_test, y_train, y_test = train_test_split( X, y, test_size=0.2, random_state=42)#divide the dataset
Total=np.concatenate((X_train,y_train),axis=1)
#Third, define a function to get minibatch from Train randomly
def next_batch():
	np.random.shuffle(Total)
	y=Total[1:101, 100:]
	X=Total[1:101, 0:100]
	return X,y

#Fourth, tensorflowde here.
loss_rate = 0.001
hidden_num = 1000
x = tf.placeholder(tf.float32, shape=[None,np.shape(X_train)[1]])
y_label = tf.placeholder(tf.float32, shape=[None, np.shape(y_train)[1]])
layer1, regularizer_1 = add_layer(x, np.shape(X_train)[1], hidden_num, activation_function=tf.nn.sigmoid)
#layer2 = add_layer(layer1, hidden_num, 40, activation_function=tf.nn.relu)
y_result, regularizer_2 = add_layer(layer1, hidden_num, np.shape(y_train)[1], activation_function = None)
cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels=y_label, logits=y_result))
loss = cross_entropy+loss_rate*(regularizer_1+regularizer_2)
train_step = tf.train.AdamOptimizer(0.005).minimize(loss)
sess = tf.InteractiveSession()
tf.global_variables_initializer().run()

for _ in range(1000):
	batch_x, batch_y = next_batch()
	train_step.run(feed_dict={x: batch_x, y_label: batch_y})

correct_prediction = tf.equal(tf.argmax(y_result, 1), tf.argmax(y_label, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
print(sess.run(accuracy, feed_dict={x: X_test,y_label: y_test}))
print(sess.run(accuracy, feed_dict={x: X_train,y_label: y_train}))