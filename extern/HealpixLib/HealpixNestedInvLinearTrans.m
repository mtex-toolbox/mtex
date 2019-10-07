% Y = HealpixNestedInvLinearTrans(X, A, m)
%
% Description
% This function calculates Y = WX where 
% W = kron( eye(12), W_0 * W_1 * W_2 * ... * W_{m-2} * W_{m-1} )
% W_i = kron( eye( 4^{m-i-1} ), V_i )
% V_i = kron( eye(4), diag([0 1 1 ... 1]) ) + kron( A, diag([1 0 0 ...0]) )
%
% Parameters
% X : input row-vector
% Y : output row-vector (same size as X)
% A : linear transform applied to the adjacent elements
% m : log4(length(X) / 12)

function Y = HealpixNestedInvLinearTrans(X, A, m)

for itr = (m - 1):(-1):0
    num_trans = 12 * 4^(m - itr - 1);
    interval = 4^itr;
    begin_idx = 1;
    %itr
    for trans = 0:(num_trans - 1)
        IDX = begin_idx + interval * [0:3];
        %IDX
        X(IDX) = A * X(IDX);
        begin_idx = begin_idx + 4 * interval;
    end
end

Y = X;
