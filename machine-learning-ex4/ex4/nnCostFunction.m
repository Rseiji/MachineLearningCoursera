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
%size(Theta2)
% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));



X = [ones(m, 1) X];
% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Forward Propagation


    z2 = Theta1 * X';
    z2 = sigmoid(z2(:,:));
   
    a2 = [ones(1,m); z2];

    z3 = Theta2 * a2;
    a3 = sigmoid(z3(:,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cost Function: Part 1: Unregularized
   
    J = 0;

    ax = a3';
    
    
    for i = 1:num_labels
       for j = 1:m
           if y(j) == i
               y_column(j,1) = 1;
           else
               y_column(j,1) = 0;
           end
       end   
        
        J = J + (1/m) * sum(((-1) * y_column) .* log(ax(:,i)) - (1 - y_column) .* log(1 - ax(:,i))); 
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Cost Function: Part 1: Regularization term

    Theta1_prod = Theta1 .* Theta1;
    Theta2_prod = Theta2 .* Theta2;

    J = J + lambda / 2 / m * (sum((sum(Theta1_prod(:,2:end)))') + sum((sum(Theta2_prod(:,2:end)))'));


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Backpropagation
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Step 1: Already done
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Step 2: delta_3
%      yk = zeros(num_labels,m);
% 
%      for t = 1:m    
%          for j = 1:num_labels
%              if y(t,1) == j    
%                  yk(j,t) = 1;
%              end
%          end
%      end   
% 
% 
%        
%      delta_3 = a3 - yk;
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Step 3: delta_2
% 
%     delta_2 = (Theta2' * (delta_3));
%     delta_2 = delta_2(2:end,:);
%     delta_temp = sigmoidGradient(z2(:,:));
%     delta_2 = delta_2 .* delta_temp;   %25x5000
%     
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Step 4: delta
%     
%      temp2 = delta_3 * (a2(:,:))';
%      temp2 = temp2 / m;
%      Theta2_grad = Theta2_grad + temp2;
%     
%      temp1 = delta_2 * X;
%      temp1 = temp1 / m;
%      Theta1_grad = Theta1_grad + temp1; %25 x 401


% =========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Backpropagation in loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    for t = 1:m
        a1 = X(t,:);
        z2 = Theta1 * a1';
        z2_perm = z2;
        z2 = sigmoid(z2(:,:));
        a2 = [1; z2];
        z3 = Theta2 * a2;
        a3 = sigmoid(z3(:,:));
    
    
        yk = zeros(num_labels,1);
        
        for j = 1:num_labels
            if y(t,1) == j    
                yk(j,1) = 1;
            end
        end

        delta_3 = a3 - yk;
        
        %delta_2 = Theta2' * delta_3;
        delta_2 = delta_3' * Theta2;
        temporario = sigmoidGradient([z2_perm(:,:)]);
        delta_2 = delta_2 .* [1; temporario]';
        
        delta_2 = delta_2(:,2:end);
        Theta1_grad = Theta1_grad + delta_2' * a1  / m;
        
        Theta2_grad = Theta2_grad + delta_3 * a2' / m;
        
    end
        
    Theta1_grad = Theta1_grad + lambda / m * Theta1;
    Theta2_grad = Theta2_grad + lambda / m * Theta2;
    
    Theta1_grad(:,1) = Theta1_grad(:,1) - lambda / m * Theta1(:,1);
    Theta2_grad(:,1) = Theta2_grad(:,1) - lambda / m * Theta2(:,1);

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
