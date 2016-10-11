function T = ctranspose(T)
% conjugate of a tensor
%
% Input
%  T - @tensor
% 
% Output
%  T - @tensor
%

switch T.rank
  
  case 1
    
  case 2
    
    T.M = conj(permute(T.M,[2 1 3:ndims(T.M)]));
    
  case 3
    
  case 4

    % check for symmetry

    % convert to a matrix    
    M = tensor42(T.M,T.doubleConvention);
    
    % invert the matrix
    M = conj(permute(M,[2 1 3:ndims(T.M)]));
    
    % make some corrections
    w = 1./(1+((1:6)>3));
    w = w.' * w;
    M = M .* w;
    
    % convert back to a 4 rank tensor
    T.M = tensor24(M,T.doubleConvention);
end

