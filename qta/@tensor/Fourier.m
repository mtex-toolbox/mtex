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
     
    CG = ClebschGordanTensor(1,1,l);
    
    if l == 0
  
      CGU = EinsteinSum(CG,[-1 -2],U,[1 -1],U,[2 -2]);
      CGUc = EinsteinSum(CG,[-1 -2],conj(U),[1 -1],conj(U),[2 -2]);
    
      THat = EinsteinSum(T,[-1 -2],CGUc,[-1 -2],CGU,[1 2]);
    
    else
      % correct tensor CG
      CG = ClebschGordanTensor(1,1,l);
      CGU = EinsteinSum(CG,[-1 -2 3],U,[1 -1],U,[2 -2]);
      CGUc = EinsteinSum(CG,[-1 -2 3],conj(U),[1 -1],conj(U),[2 -2]);
    
      % sum everythink up
      THat = EinsteinSum(T,[-1 -2],CGUc,[-1 -2 4],CGU,[1 2 3]);
    end
    
  case 3
    
    % multiply with conj(U)
    T = EinsteinSum(T,[-1 -2 -3],conj(U),[-1 1],conj(U),[-2 2],conj(U),[-3 3]);

    J2 = l;
    % compute decomposition 
    THat = tensor(zeros([3 3 3 2*l+1 2*l+1]));
    for J1 = max(l-1,0):2
      
      CG1J1  = ClebschGordanTensor(1,1,J1);
      CGJ1J2 = ClebschGordanTensor(J1,1,J2);
    
      THat = THat + EinsteinSum(T,[-1 -2 -3],CG1J1,[-1 -2 -4],...
        CGJ1J2,[-4 -3 5],CG1J1,[1 2 -5],CGJ1J2,[-5 3 4]);
    
    end
    
    % multiply with U
    THat = EinsteinSum(THat,[-1 -2 -3],U,[-1 1],U,[-2 2],U,[-3 3]);
end

