function THat = Fourier(T,varargin)
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

U = tensorU;

l = get_option(varargin,'order',1);

switch rank(T)

  case 1
  
    if l == 1
      THat = EinsteinSum(T,-1,conj(U),[-1 3],U,[1 2]);
    else
      THat = tensor(zeros(size(T)));
    end
  
  case 2
     
    if l == 0
  
      CGU = EinsteinSum(ClebschGordanTensor(l),[-1 -2],U,[1 -1],U,[2 -2]);
      CGUc = EinsteinSum(ClebschGordanTensor(l),[-1 -2],conj(U),[1 -1],conj(U),[2 -2]);
    
      THat = EinsteinSum(T,[-1 -2],CGUc,[-1 -2],CGU,[1 2]);
    
    else
      % correct tensor CG
      CGU = EinsteinSum(ClebschGordanTensor(l),[-1 -2 3],U,[1 -1],U,[2 -2]);
      CGUc = EinsteinSum(ClebschGordanTensor(l),[-1 -2 3],conj(U),[1 -1],conj(U),[2 -2]);
    
      % sum everythink up
      THat = EinsteinSum(T,[-1 -2],CGUc,[-1 -2 4],CGU,[1 2 3]);
    end
    
end

