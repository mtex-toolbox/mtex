function vol = volume(pf,q,radius)
% ratio of vectors with a certain direction
%
% Description
% returns the ratio of mass of the polefigure at a given location
%
% Syntax
%   v = volume(pf,center,radius)
%
% Input
%  odf    - @ODF
%  center - @orientation / @vector3d
%  radius - double
%
% See also
% ODF/volume


for k=1:numel(pf)
  
  if isa(q,'quaternion')
    v = pf(k).SS*quaternion(q)*symmetrise(pf(k).h);
  else
    v = q;
  end
  
  d = pf(k).intensities;
  v = any(find(pf(k).r,v,radius),2);
  v = reshape(full(v),size(d));  
  
  vol(k) = sum(d.*v)./sum(d);
  
end
