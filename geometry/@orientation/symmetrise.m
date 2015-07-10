function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations

ap = o.antipodal;
if check_option(varargin,'proper')  
  o = orientation(symmetrise@rotation(o,o.CS.properGroup,o.SS.properGroup),o.CS,o.SS);
else
  o = orientation(symmetrise@rotation(o,o.CS,o.SS),o.CS,o.SS);
end
o.antipodal = ap;

if o.antipodal
  o = [o;inv(o)];
end
