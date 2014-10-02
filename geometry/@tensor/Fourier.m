function THat = Fourier(T,varargin)
% compute the Fourier coefficients of the tensor
%
% Description
%
% Input
%  T - @tensor
%
% Options
%  order - 
%
% Output
%  F - Fourier coefficients as an 2*rank+1 x 2*rank + 1 matrix
%

l = get_option(varargin,'order',1);
THat = tensor(zeros([repmat(3,1,T.rank) 2*l+1 2*l+1]),'rank',T.rank+2,'noCheck');

U = tensorU;

switch T.rank

  case 1
  
    if l == 1
      THat = EinsteinSum(T,-1,conj(U),[-1 3],U,[1 2]);
    end
  
  case 2
     
    % multiply T with conj(U)    
    T = EinsteinSum(T,[-1 -2],conj(U),[-1 1],conj(U),[-2 2]);
    
    % multiply with Clebsch Gordan Coefficients
    CG = ClebschGordanTensor(1,1,l);
    THat = EinsteinSum(T,[-1 -2],CG,[-1 -2 4],CG,[1 2 3]);
      
    % multiply with U
    THat = EinsteinSum(THat,[-1 -2 3 4],U,[1 -1],U,[2 -2]);
   
  case 3
    
    % multiply with conj(U)
    T = EinsteinSum(T,[-1 -2 -3],conj(U),[-1 1],conj(U),[-2 2],conj(U),[-3 3]);

    J2 = l;
    % compute decomposition 

    for J1 = max(l-1,0):2
      
      CG1J1  = ClebschGordanTensor(1,1,J1);
      CGJ1J2 = ClebschGordanTensor(J1,1,J2);
    
      THat = THat + EinsteinSum(T,[-1 -2 -3],CG1J1,[-1 -2 -4],...
        CGJ1J2,[-4 -3 5],CG1J1,[1 2 -5],CGJ1J2,[-5 3 4]);
    
    end
    
    % multiply with U
    THat = EinsteinSum(THat,[-1 -2 -3 4 5],U,[1 -1],U,[2 -2],U,[3 -3]);
    
  case 4
    
    % multiply with conj(U)
    T = EinsteinSum(T,[-1 -2 -3 -4],conj(U),[-1 1],conj(U),[-2 2],...
      conj(U),[-3 3],conj(U),[-4 4]);

    J0 = l;
    % compute decomposition 

    for J1 = 0:2
      for J2 = 0:2
    
        CG11J1  = ClebschGordanTensor(1,1,J1);
        CG11J2  = ClebschGordanTensor(1,1,J2);
        CGJ1J2J0 = ClebschGordanTensor(J1,J2,J0);
    
        THat = THat + EinsteinSum(T,[-1 -2 -3 -4],...
          CG11J1,[-1 -2 -5],...
          CG11J2,[-3 -4 -6],...
          CGJ1J2J0,[-5 -6 6],...
          CG11J1,[1 2 -7],...
          CG11J2,[3 4 -8],...
          CGJ1J2J0,[-7 -8 5]);
        
      end   
    end
    
    % multiply with U
    THat = EinsteinSum(THat,[-1 -2 -3 -4 5 6],U,[1 -1],...
      U,[2 -2],U,[3 -3],U,[4 -4]);
    
end

