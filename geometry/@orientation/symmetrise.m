function o = symmetrise(o,varargin)  
% all crystallographically equivalent orientations

ap = o.antipodal;

if nargin > 1 && isa(varargin{1},'symmetry')
  CS = varargin{1};
  SS = getClass(varargin(2:end),'symmetry',specimenSymmetry);
else
  CS = o.CS;
  SS = o.SS;
end

if check_option(varargin,'proper')
  CS = CS.properGroup;
  SS = SS.properGroup;
end
o = orientation(symmetrise@rotation(o,CS,SS),o.CS,o.SS);

o.antipodal = ap;

if o.antipodal
  o = [o;inv(o)];
end

if check_option(varargin,'unique')
  [~,ind] = unique(rotation(o));
  o = subSet(o,ind);
end
