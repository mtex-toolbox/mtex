function [m,im,iu] = unique(m,varargin)
% disjoint list of Miller indices%
%
% Syntax
%   u = unique(m) % find disjoined elements of the vector v
%   u = unique(m,'tolerance',0.01) % use tolerance 0.01
%   [u,im,iu] = unique(m,varargin)] 
%
% Input
%  m   - @Miller
%  tol - double (default 1e-7)
%
% Output
%  u - @Miller
%  im - index such that u = m(im)
%  iu - index such that m = u(iu)
%
% Flags
%  stable     - prevent sorting
%  noSymmetry - ignore symmetry
%
% See also
% unique
%

if check_option(varargin,'noSymmetry')
    
  [~,im,iu] = unique@vector3d(m,varargin{:});
  
else
  v = vector3d(symmetrise(m,varargin{:}));
  
  [~,~,iu] = unique(v,varargin{:});

  [~,im,iu] = unique(min(reshape(iu,size(v)),[],1));
 
end

m = m.subSet(im);
