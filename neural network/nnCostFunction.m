function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices.
%
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);

% You need to return the following variables correctly
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

    temp = zeros(m,num_labels);
    for i = 1:m
        if(y(i) == 0)
            y(i) = 10;
        end
        pos = y(i);
        temp(i,pos) = 1;
    end;
    y = temp;

    a1 = [ones(m,1) X];
    z2 = a1 * Theta1';
    a2 = [ones(m,1) sigmoid(z2)];
    
    z3 = a2 * Theta2';
    h = sigmoid(z3);
    
    J = (sum(sum(diag(- log(h) * y' - log(1 - h) * (1 - y')))) + (lambda * (sum(sum((Theta1(:,2:end)).^2)) + sum(sum((Theta2(:,2:end)).^2))) / 2)) / m;

    delta3 = h - y;
    delta2 =  delta3 * Theta2(:,2:end) .* sigmoidGradient(z2);%5000*25

    Theta1_grad = (Theta1_grad + (delta2' * a1) + lambda * Theta1) / m;
    Theta2_grad = (Theta2_grad + (delta3' * a2) + lambda * Theta2 ) / m;
    A = (delta2' * a1);
    B = (delta3' * a2);
    Theta1_grad(:,1) = A(:,1) / m;
    Theta2_grad(:,1) = B(:,1) / m;

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
