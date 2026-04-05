function v = rotate_outer(v,q,varargin)
% rotate vector3d by quaternion
%
% Syntax
%   v = rotate_outer(v,20*degree) % rotation about the z-axis
%   rot = rotation_outer.byEuler(10*degree,20*degree,30*degree)
%   v = rotate_outer(v,rot)
%
% Input
%  v - @vector3d
%  q - @quaternion
%
% Output
%  r - q * v;
%

if isnumeric(q), q = axis2quat(zvector,q);end

% bring the coefficient into the right shape
[a,b,c,d] = double(q); a = a(:); b = b(:); c = c(:); d = d(:);
[x,y,z] = double(v); x = x(:).'; y = y(:).'; z = z(:).';

%rotation
xx = (a.^2+b.^2-c.^2-d.^2)*x + 2*( (a.*c+b.*d)*z + (b.*c-a.*d)*y );
yy = (a.^2-b.^2+c.^2-d.^2)*y + 2*( (a.*d+b.*c)*x + (c.*d-a.*b)*z );
zz = (a.^2-b.^2-c.^2+d.^2)*z + 2*( (a.*b+c.*d)*y + (b.*d-a.*c)*x );

% apply inversion if needed
if isa(q,'rotation')
  ind = isImproper(q);
  if any(ind(:))
    xx(ind,:) = -xx(ind,:);
    yy(ind,:) = -yy(ind,:);
    zz(ind,:) = -zz(ind,:);
  end
end

v = setXYZ(v,xx,yy,zz);
%v = vector3d(xx,yy,zz);

% remove any stored theta / rho angles
if ~isempty(fieldnames(v.opt)), v = rmOption(v,'theta','rho'); end

% if q is orientation change reference frame / plottingConvention
if isa(q,'orientation')
  
  % if output has symmetry convert to Miller
  if isa(q.SS,'crystalSymmetry')
    v = Miller(v,q.SS);
    v.dispStyle = MillerConvention(v.dispStyle);
    v.dispStyle = make4Digit(v.dispStyle,q.SS);
    
  else

    % convert to vector3d
    if isa(v,"Miller"), v = vector3d(v); end

    v.how2plot = q.SS.how2plot;

  end

end

% normal result is length(q) x length(v)
% special cases are when length(q) == 1 or length(v)==1
if isscalar(x) && ~isscalar(a)
  v = reshape(v,size(a));
elseif isscalar(a) && ~isscalar(x)
  v = reshape(v,size(x));
end


