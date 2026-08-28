function v = rotate(v,q,varargin)
% rotate vector3d by rotation or orientation
%
% Syntax
%   v = rotate(v,20*degree) % rotation about the z-axis
%   rot = rotation.byEuler(10*degree,20*degree,30*degree)
%   v = rotate(v,rot)
%
% Description
%  Either |v| or |rot| are single elements or both have the same size. The
%  output |v| will have the same size as the bigger of both input arrays.
%
% Input
%  v - @vector3d
%  q - @quaternion
%
% Output
%  r - q * v
%

if isnumeric(q), q = axis2quat(zvector,q);end

% an orientation has to act on the frame the data is expressed in - the
% symmetries need not agree, only the frames have to fit
if isa(q,'orientation'), q = fitFrame(q,v.frame); end

wasNormalized = v.isNormalized;

if ~isa(q,'rotation')
  [a,b,c,d] = double(q);
  i = [];
else
  [a,b,c,d,i] = double(q);
end
[x,y,z] = double(v);

n = b.^2 + c.^2 + d.^2;
s = 2*(x.*b + y.*c + z.*d);

a_2 = 2*a;
a_n  = a.^2 - n;

v.x = a_2.*(c.* z - y.*d) + s.*b + a_n.*x;
v.y = a_2.*(d.* x - z.*b) + s.*c + a_n.*y;
v.z = a_2.*(b.* y - x.*c) + s.*d + a_n.*z;

if ~isempty(i) 
  if numel(i)>1
    i = logical(i);
    v.x(i) = -v.x(i);
    v.y(i) = -v.y(i);
    v.z(i) = -v.z(i);
  elseif i
    v.x = -v.x;
    v.y = -v.y;
    v.z = -v.z;
  end
end

v = rmOption(v,'theta','rho');


if isa(q,'orientation')

  % an orientation takes the result into the frame it maps into, a rotation
  % keeps it where it was
  v.frame = q.frameB;

  % a direction in a crystal frame is written in indices
  if isa(q.frameB,'crystalFrame')

    if v.dispStyle == MillerConvention.xyz, v.dispStyle = MillerConvention.hkl; end
    v.dispStyle = make4Digit(MillerConvention(v.dispStyle),q.frameB);

  else

    % leaving the crystal frame the direction is no longer written in indices
    v.dispStyle = MillerConvention.xyz;

  end

end

v.isNormalized = wasNormalized ;
