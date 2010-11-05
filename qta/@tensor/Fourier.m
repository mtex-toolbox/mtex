function [F T] = Fourier(T)
% compute the Fourier coefficients of the tensor
%
%% Description
%
%% Input
%  T - @tensor
%
%% Output
%  F - Fourier coefficients as an 2*rank+1 x 2*rank + 1 matrix
%

%% step one - multiply tensor with U 
U = tensorU;



%% step two - compute tensor representations

%T = EinsteinSum()

if rank(T) == 1
  T = rotate(T,U.');
  T = EinsteinSum(T,2,eye(3),[1 3]);
elseif rank(T) == 2
  C = tensorClebschGordan;
  
  T = EinsteinSum(T,[-1 -2],U,[],U[])
  
  %T = EinsteinSum(T,[-1 -2],C,[-1 -2 3],C,[1 2 4]);
  
  
  
  return
end



%% step three - multiply with tensor U'
T.rank = T.rank - 2;
T = rotate(T,conj(U));
T.rank = T.rank + 2;


F = T.M;

end
