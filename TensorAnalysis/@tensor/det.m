function d = det(T)
% compute the determinants of rank 2 tensors
%
% Synatx
%
%   d = det(T)
%
% Input
%  d - rank 2 @tensor
%
% Output
%  d - double
%

switch T.rank
  case 2

    d = det3(T.M);
  
  case 4
    
    % convert to a matrix
    M = tensor42(T.M,2);

    % determinant of the matrix
    d = zeros(size(T));
    for l = 1:length(T)
      d(l) = det(M(:,:,l));
    end

  otherwise
    error('Determinant is only implemented for tensors of rank 2 and 4')
end

end