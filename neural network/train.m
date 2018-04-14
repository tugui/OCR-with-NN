%% Initialization
clear ; close all; clc

%% Setup the parameters you will use for this exercise
input_layer_size  = 400;  % 20x20 Input Images of Digits
hidden_layer_size = 25;   % 25 hidden units
num_labels = 10;          % from 1 to 10 (note that we have mapped "0" to label 10)

batch_size = 10000;
batch_number = 1;

lambda = 3;
options = optimset('MaxIter', 500);

load training_imgs
X = training_imgs;
y = training_labels;
training_imgs = [];
training_labels = [];

%% Training
fprintf('\nTraining Neural Network... \n')
Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
Theta2 = randInitializeWeights(hidden_layer_size, num_labels);
for k = 1:batch_number
    nn_params = [Theta1(:) ; Theta2(:)];
    costFunction = @(p) nnCostFunction(p, input_layer_size, hidden_layer_size, num_labels, ...
                                       X((k-1)*batch_size+1:k*batch_size,:), ...
                                       y((k-1)*batch_size+1:k*batch_size,:), lambda);
    [nn_params, cost] = fmincg(costFunction, nn_params, options);
    Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                     hidden_layer_size, (input_layer_size + 1));
    Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                     num_labels, (hidden_layer_size + 1));
end

save Theta1.mat Theta1
save Theta2.mat Theta2
%pred = predict(Theta1, Theta2, X(1:batch_number*batch_size,:));
%fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y(1:batch_number*batch_size,:))) * 100);

pred = predict(Theta1, Theta2, X(batch_number*batch_size+1:(batch_number+1)*batch_size,:));
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y(batch_number*batch_size+1:(batch_number+1)*batch_size,:))) * 100);
