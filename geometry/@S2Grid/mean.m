function m = mean(S2G,varargin)
% computes the mean vector 
%
%% Input
%  v - @vector3d
%
%% Output
%  m - @vector3d
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
% 

if check_option(S2G,'antipodal')
  varargin = ['antipodal',varargin];
end

m = mean(S2G.vector3d,varargin{:});
