function uvtw = v2d(m,varargin)
% vector3d --> Miller-indece (u,v,w)
%
% Syntax
%  [u,v,w] = v2d(m)
%
% Input
%  m - @Miller
%
% Output
%  u,v,w - integer

% set up matrix

[x,y,z] = double(m.CS.axes);
M = [x;y;z];

% compute Miller indice
mdouble = reshape(double(m),[],3).';

uvtw = (M \ mdouble)';

if m.lattice.isTriHex
      
  uvtw(:,4) = uvtw(:,3);
  uvtw(:,3) = -(uvtw(:,1) + uvtw(:,2))./3;
  [uvtw(:,1), uvtw(:,2)] = deal((2*uvtw(:,1)-uvtw(:,2))./3,(2*uvtw(:,2)-uvtw(:,1))./3);
  
end

