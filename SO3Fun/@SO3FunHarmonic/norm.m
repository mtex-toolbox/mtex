function t = norm(F)
% caclulate the norm of an rotational harmonic
%
% Input
%  F - @SO3FunHarmonic 
%
% Output
%  norm - double

t = F.fhat;
  for l = 0:dim2deg(numel(t))
    t(deg2dim(l)+1:deg2dim(l+1)) = t(deg2dim(l)+1:deg2dim(l+1)) ./ sqrt(2*l+1);    
  end
t=norm(t);