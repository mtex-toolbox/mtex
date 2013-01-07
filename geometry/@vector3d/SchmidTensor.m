function m = SchmidTensor(n,b,varargin)
% computes the Schmidt tensor
%
%% Input
%  n - normal vector the the slip or twinning plane
%  b - Burgers vector (slip) or twin shear direction (twinning)
%
%% Output
%  m - Schmid tensor
%
%% Options
%
%  generalized   - 
%  symmetric     - default
%  antisymmetric -
%
%%
%

tn = tensor(n);
tb = tensor(b);

if check_option(varargin,'generalized')
  
  m = EinsteinSum(tn,1,tb,2);
  
elseif check_option(varargin,'antisymmetric')
  
  m = 0.5*(EinsteinSum(tn,1,tb,2) - EinsteinSum(tn,2,tb,1));
  
else
  
  m = 0.5*(EinsteinSum(tn,1,tb,2) + EinsteinSum(tn,2,tb,1));
  
end

if isa(n,'Miller'), m = set(m,'CS',get(n,'CS')); end

end

