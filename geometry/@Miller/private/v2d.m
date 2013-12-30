function uvtw = v2d(m,varargin)
% vector3d --> Miller-indece (u,v,w)
%
%% Syntax
%  [u,v,w] = v2d(m)
%
%% Input
%  m - @Miller
%
%% Output
%  u,v,w - integer

%% set up matrix

[x,y,z] = double(get(m.CS,'axis'));
M = [x;y;z];

%% compute Miller indice
mdouble = reshape(double(m),[],3).';

uvtw = (M \ mdouble)';

if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
    
  uvtw(:,4) = uvtw(:,3);
  uvtw(:,3) = -(uvtw(:,1) + uvtw(:,2))./3;
  [uvtw(:,1), uvtw(:,2)] = deal((2*uvtw(:,1)-uvtw(:,2))./3,(2*uvtw(:,2)-uvtw(:,1))./3);
  
end

