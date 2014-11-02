%% Neural Network based Indirect Channel Estimation
%% Initialization
clear ; close all; clc
% Setup the parameters you will use for this exercise
input_layer_size  = 80;     % Num of features
hidden_layer_size = 30;     % 25 hidden units
num_labels = 5;             % Num of SBS is 5

%% Loading and Visualizing Data
%  We start the exercise by first loading and visualizing the dataset. 
%  You will be working with a dataset that contains handwritten digits.
%
fprintf('Preprocessing and Loading Data ...\n')
% Load Training Data
[X,y] = Preprocessing('../channelGen/data_with_80antennas.mat');
m = size(X, 1);
X_val = X(1:2:end,:); y_val = y(1:2:end,:);
X_train = X(2:2:end,:); y_train = y(2:2:end,:);

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

options = optimset('MaxIter', 1000);
lambda = 0.1;
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


