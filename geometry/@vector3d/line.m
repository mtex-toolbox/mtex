function varargout = line(v,varargin)
%
% Syntax
%
%   line(v)
%   line(v1,v2)
%
% Input
%  v, v1, v2 - @vector3d

% if two argument are given interpolate between those
if nargin > 1 && isa(varargin{1},'vector3d')
  v1 = reshape(v,1,[]);
  v2 = reshape(varargin{1},1,[]);
  varargin(1) = [];
  
  % the normal vector
  n = repmat(cross(v1,v2),100,1);
  
  % the angles
  omega = linspace(0,1,100).' * angle(v1,v2);
  
  v = rotation.byAxisAngle(n,omega) .* repmat(v1,100,1);
  
  % add a nan after each segment
  v = [v;vector3d.nan(1,length(v1))];

  varargin = delete_option(varargin,{'label','labeled'},[1,0]);
  [varargout{1:nargout}] = line(v,varargin{:});
  
  return
end

[varargout{1:nargout}] = scatter(reshape(v,[],1),varargin{:},'edgecolor',...
  get_option(varargin,{'color','linecolor'},'k'),'Marker','none','scatter_resolution',1*degree);
