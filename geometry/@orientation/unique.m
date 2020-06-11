function [ori,ndx,pos] = unique(ori,varargin)
% disjoint list of orientations
%
% Syntax
%   u = unique(ori)
%   u = unique(ori,'tolerance',0.01)
%   [u,iori,iu] = unique(ori)
%
% Input
%  ori - @orientation
%  tol - double (default 1e-3)
%
% Output
%  u - @orientation
%  iori - index such that u = ori(iori)
%  iu   - index such that ori = u(iu)
%
% Flags
%  stable     - prevent sorting
%  noSymmetry - ignore symmetry
%
% See also
% unique
%

if check_option(varargin,'noSymmetry')
    
  [~,ndx,pos] = unique@rotation(ori,varargin{:});
  
else
  rot = rotation(symmetrise(ori,varargin{:}));
  
  [~,~,pos] = unique(rot,varargin{:});

  [~,ndx,pos] = unique(min(reshape(pos,size(rot)),[],1));
 
end

ori = ori.subSet(ndx);