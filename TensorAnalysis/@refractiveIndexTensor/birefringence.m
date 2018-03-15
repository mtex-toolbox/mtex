function [n,nMin,nMax] = birefringence(rI,vprop)
%
% Syntax
%
% Input
%  vprop - propagation direction
%  rI
    
% first we need two arbitrary orthogonal directions orthogonal to vprop
p1 = orth(vprop(:));
p2 = rotation('axis',vprop(:),'angle',90*degree) .* p1;

B11 = EinsteinSum(rI,[-1 -2],p1,-1,p1,-2);
B12 = EinsteinSum(rI,[-1 -2],p1,-1,p2,-2);
B22 = EinsteinSum(rI,[-1 -2],p2,-1,p2,-2);

[v,lambda] = eig2(B11,B12,B22);

n = lambda(2,:) - lambda(1,:);
if nargout > 1
  
 nMin = sum([p1,p2] .* squeeze(v(:,1,:)).',2);
 nMax = sum([p1,p2] .* squeeze(v(:,2,:)).',2);
  
end

end