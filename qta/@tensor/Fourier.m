function [F T] = Fourier(T,varargin)
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

l = get_option(varargin,'order',1);

%% step two - compute tensor representations

%T = EinsteinSum()

if rank(T) == 1
  
  if l == 1
    T = rotate(T,U.');
    T = EinsteinSum(T,2,eye(3),[1 3]);
  else
    T.M(:) = 0;
  end
  
elseif rank(T) == 2
  
  C = tensorClebschGordan;
  
  T = EinsteinSum(T,[-1 -2],U,[],U,[1])
  
  %T = EinsteinSum(T,[-1 -2],C,[-1 -2 3],C,[1 2 4]);
  
  
  
  return
end



%% step three - multiply with tensor U'
T.rank = T.rank - 2;
T = rotate(T,conj(U));
T.rank = T.rank + 2;


F = T.M;

end
