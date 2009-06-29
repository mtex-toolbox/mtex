function ebsd = rotate(ebsd,q,flag)
% rotate EBSD orientations or spatial data around point of origin
%
%% Input
%  ebsd - @EBSD
%  q    - @quaternion
%
%% Option
%  xy/spatial - rotate spatial data
%
%% Output
%  rotated ebsd - @EBSD

if nargin > 2 && any(strcmpi(flag,{'xy','spatial'})) && isa(q,'double')
  A = [cos(q) -sin(q);sin(q) cos(q)];  
  ebsd = affinetrans(ebsd,A);
  return
end

if isa(q,'double')
  q = axis2quat(zvector,q);
end

for i = 1:length(ebsd)  
  ebsd(i).orientations = q * ebsd(i).orientations;
end


