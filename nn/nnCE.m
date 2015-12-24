%% Neural Network based Indirect Channel Estimation
%% version:  V3.0.0 
%©°©¸©´©¼©¤©¦©À©È©Ð©Ø©à
%=============================================================
% Changes:
%  ©¸reform input & Parameter
%=============================================================
% Todos:  


%% Initialization
% clear ; close all; clc
% Setup the parameters you will use for this exercise
N_MBS=20;
N_frequency=11;
N_MS=2000;
input_layer_size  = N_MBS*N_frequency;     % Num of features
hidden_layer_size = 100;     % No. of hidden units
num_labels = 10;             % No. of SBS

%% Loading and Visualizing Data
%  We start the exercise by first loading and visualizing the dataset. 
%  You will be working with a dataset that contains handwritten digits.
%
fprintf('Preprocessing and Loading Data ...\n')
% Load Training Data

file = ['../channelGen/2D_data_with_2150+-50MHz_11_samples_20_antennas_fixed_10_SBSs_10_scatterers_',num2str(N_MS),'_MSs.mat'];
[X,y] = Preprocessing(file);
%load(file);
m = size(X, 1);
% random select training and validation sets
[trainInd,valInd]=dividerand(m,0.5,0.5,0);  
X_val = X(valInd,:); y_val = y(valInd,:);
X_train = X(trainInd,:); y_train = y(trainInd,:);

% % divide data into halves
% X_val = X(1:end/2,:); y_val = y(1:end/2,:);
% X_train = X(end/2+1:end,:); y_train = y(end/2+1:end,:);

%% Initializing Pameters
%  In this part of the exercise, you will be starting to implment a two
%  layer neural network that classifies digits. You will start by
%  implementing a function to initialize the weights of the neural network
%  (randInitializeWeights.m)

fprintf('\nInitializing Neural Network Parameters ...\n')
% 
initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);
% 
% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];


%% Training NN
%  You have now implemented all the code necessary to train a neural 
%  network. To train your neural network, we will now use "fmincg", which
%  is a function which works similarly to "fminunc". Recall that these
%  advanced optimizers are able to train our cost functions efficiently as
%  long as we provide them with the gradient computations.
%
fprintf('\nTraining Neural Network... \n')

options = optimset('MaxIter', 500);
lambda = 1;
costFunction = @(p) nnCostFunction(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, X_train, y_train, lambda);

% Now, costFunction is a function that takes in only one argument (the
% neural network parameters)
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% Obtain Theta1 and Theta2 back from nn_params
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));


%% Implement Predict
%  After training the neural network, we would like to use it to predict
%  the labels. You will now implement the "predict" function to use the
%  neural network to predict the labels of the training set. This lets
%  you compute the training set accuracy.

pred_train = predict(Theta1, Theta2, X_train);
pred_val = predict(Theta1, Theta2, X_val);
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred_train == y_train)) * 100);
fprintf('\nValidation Set Accuracy: %f\n', mean(double(pred_val == y_val)) * 100);


