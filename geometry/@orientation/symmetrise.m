function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations

ap = o.antipodal;
CS = o.CS;
if check_option(varargin,'proper')
  o.CS = CS.properGroup;
end
o = orientation(symmetrise@rotation(o,o.CS,o.SS),CS,o.SS);

o.antipodal = ap;

if o.antipodal
  o = [o;inv(o)];
end

if check_option(varargin,'unique')
  [~,ind] = unique(rotation(o));
  o = subSet(o,ind);
end
