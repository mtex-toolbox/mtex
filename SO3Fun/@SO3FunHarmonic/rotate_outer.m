function SO3F = rotate_outer(SO3F,rot,varargin)
% rotate a function on SO(3)
%
% Syntax
%   SO3F = SO3F.rotate_outer(rot)
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot  - @rotation
%
% Output 
%  SO3F - @SO3FunHarmonic
%
    
L = SO3F.bandwidth;
D = WignerD(rot,'bandwidth',L);

for l = 0:L
  SO3F.fhat(deg2dim(l)+1:deg2dim(l+1)) = ...
    reshape(SO3F.fhat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1) * ...
    reshape(D(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1).' ;
end
    
end
