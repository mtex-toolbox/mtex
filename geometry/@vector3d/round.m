function v = round(v,varargin)
% tries to round xyz coordinates to greatest common divisor

vOld = v;

xyz = [v.x(:),v.y(:),v.z(:)].';

% the 
xyzMax = reshape(max(abs(xyz),[],1),size(v));

maxInt = get_option(varargin,'maxXYZ',12);

multiplier = ones(size(v));
for im = 1:size(xyz,2)
  
  mNew = xyz(:,im) / xyzMax(im) * (1:maxInt);  
  
  e = 1e-7 * round(1e7 * sum((mNew - round(mNew)).^2)./sum(mNew.^2));
    
  [~,n] = min(e);
  
  multiplier(im) = n / xyzMax(im);
  
end

v = v .* multiplier;

% now round
v.x = round(v.x); v.y = round(v.y); v.z = round(v.z);

d = angle(v,vOld) > 1*degree;
v.x(d>0.1*degree) = vOld.x(d);
v.y(d>0.1*degree) = vOld.y(d);
v.z(d>0.1*degree) = vOld.z(d);