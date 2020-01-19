function o = symmetrise(o,varargin)  
% all crystallographically equivalent orientations

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
o = symmetrise@rotation(o,CS,SS);

if o.antipodal
  o = [o;inv(o)];
end

if check_option(varargin,'unique')
  [~,ind] = unique(o,'noSymmetry');
  o = subSet(o,ind);
end
