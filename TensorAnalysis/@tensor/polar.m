function [R,SL,SR] = polar(T)
% compute the polar decomposition of rank 2 tensors
%
% Syntax
%   [R,SL] = polar(T)
%   [R,SL,SR] = polar(T)
%
% Input
%  T - rank 2 @tensor
%
% Output
%  R - orthogonal rank 2 @tensor 
%  SL - symmetric rank 2 @tensor such that SL * R = T
%  SR - symmetric rank 2 @tensor such that R * SR = T
%

R = zeros(3,3,length(T));
SR = zeros(3,3,length(T));
if nargout == 3, SL = SR; end
switch T.rank

  case 2
    for i = 1:length(T)
      [U,S,V] = svd(T.M(:,:,i));
      R(:,:,i) = U * V';
      SL(:,:,i) = U * S * U';
      if nargout == 3
        SR(:,:,i) = V * S * V';
      end
    end
    
    R = tensor(R,'rank',2);
    SR = tensor(SR,'rank',2);
    SL = tensor(SL,'rank',2);
  otherwise
    error('no idea what to do!')
end
