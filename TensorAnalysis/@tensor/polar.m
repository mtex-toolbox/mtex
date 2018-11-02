function [R,SR,SL] = polar(T)
% compute the polar decomposition of rank 2 tensors
%
% Syntax
%   [R,SR] = polar(T)
%   [R,SR,SL] = polar(T)
%
% Input
%  T - rank 2 @tensor
%
% Output
%  R - orthogonal rank 2 @tensor 
%  SR - symmetric rank 2 @tensor such that R * SR = T
%  SL - symmetric rank 2 @tensor such that SL * R = T
%

R = zeros(3,3,length(T));
SR = zeros(3,3,length(T));
if nargout == 3, SL = SR; end
switch T.rank

  case 2
    for i = 1:length(T)
      [U,S,V] = svd(T.M(:,:,i));
      R(:,:,i) = U * V';
      SR(:,:,i) = V * S * V';
      if nargout == 3
        SL(:,:,i) = U * S * U';
      end
    end
    
    R = tensor(R,'rank',2);
    SR = tensor(SR,'rank',2);
    if nargout == 3, SL = tensor(SL,'rank',2); end
  otherwise
    error('no idea what to do!')
end

