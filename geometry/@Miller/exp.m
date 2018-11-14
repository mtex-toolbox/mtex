function ori = exp(m,ori_ref,varargin)
% misorientation vector to misorientation
%
% Description
% 
% Syntax
%
%   mori = exp(m)        % misorientation
%
%   ori = exp(m,ori_ref) % orientation update
%
% Input
%  m - @Miller misorientation vector in crystal coordinates
%  ori_ref - @orientation
%
% Output
%  ori - @orientation
%
% See also
% Miller/exp orientation/log

rot = exp@vector3d(m);

ori = orientation(rot,m.CS,m.CS);

if nargin >= 2
  if check_option(varargin,'left')
    ori =  ori * ori_ref;
  else
    ori =  ori_ref .* ori;
  end
end