function [ori,ndx,pos] = unique(ori,varargin)
% disjoint list of quaternions
%
% Syntax
%   ori = unique(ori)
%   [ori,ndx,pos] = unique(ori) %
%
% Input
%  ori - @orientation
%
% Output
%  ori - @orientation

if check_option(varargin,'noSymmetry')
    
  [~,ndx,pos] = unique@rotation(ori,varargin{:});
  
else
  rot = rotation(symmetrise(ori,varargin{:}));
  
  [tmp1,tmp2,pos] = unique(rot,varargin{:}); %#ok<ASGLU>

  [tmp,ndx,pos] = unique(min(reshape(pos,size(rot)),[],1)); %#ok<ASGLU>
 
end

ori = ori.subSet(ndx);