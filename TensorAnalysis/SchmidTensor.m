function m = SchmidTensor(n,b,varargin)
% computes the Schmidt tensor
%
% Input
%  n - normal vector of the slip or twinning plane
%  b - Burgers vector (slip) or twin shear direction (twinning)
%
% Output
%  m - Schmid tensor
%
% Options
%
%  generalized   - 
%  symmetric     - default
%  antisymmetric -
%

% normalize and convert to tensor
tn = tensor(n.normalize,'noCheck');
tb = tensor(b.normalize,'noCheck');

if check_option(varargin,'generalized')
  
  m = EinsteinSum(tn,1,tb,2,'name','generalized Schmid');
  
elseif check_option(varargin,'antisymmetric')
  
  m = 0.5*(EinsteinSum(tn,1,tb,2,'name','antisymmetric Schmid') - EinsteinSum(tn,2,tb,1));
  
else
  
  m = 0.5*(EinsteinSum(tn,1,tb,2,'name','symmetric Schmid') + EinsteinSum(tn,2,tb,1));
  
end

% this should not be a crystal tensor - explain why!!
%if isa(n,'Miller'), m.CS = n.CS; end

end

