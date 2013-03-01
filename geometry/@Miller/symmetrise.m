function varargout = symmetrise(m,varargin)
% directions symmetrically equivalent to m
%
%% Syntax
%  m = symmetrise(m) - @Miller indice symmetrically equivalent to m
%
%% Input
%  m - @Miller
%
%% Output
%  v - @Miller
%
%% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]

%% !!!!!! very bad workaround !!!!!!!!
% somtimes this function gets called although first argument is vector3d
if ~isa(m,'Miller')
  isMiller = cellfun(@(x) isa(x,'Miller'),varargin);
  varargin(isMiller) = [];
  [varargout{1:nargout}] = symmetrise(m,varargin{:});
  return
end  

%%
if nargout==2
  [m.vector3d,l] = symmetrise(m.vector3d,m.CS,varargin{:});
  varargout = {m,l};
else
  m.vector3d = symmetrise(m.vector3d,m.CS,varargin{:});
  varargout = {m};
end
