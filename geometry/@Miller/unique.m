function [m,ndx,pos] = unique(m,varargin)
% disjoint list of Miller indices
%
% Syntax
%   m = unique(m)           % 
%   [m,ndx,pos] = unique(m) %
%
% Input
%  m - @Miller
%
% Output
%  m - @Miller

if check_option(varargin,'noSymmetry')
    
  [~,ndx,pos] = unique@vector3d(m,varargin{:});
  
else
  v = vector3d(symmetrise(m,varargin{:}));
  
  [tmp1,tmp2,pos] = unique(v,varargin{:}); %#ok<ASGLU>

  [tmp,ndx,pos] = unique(min(reshape(pos,size(v)),[],1)); %#ok<ASGLU>
 
end

m = m.subSet(ndx);
