function varargout = line(rot,varargin)
% draw rotations connected by lines
%
% Syntax
%   line(rot,'linecolor','r','linewith',2)
%
% Input
%  rot - list of @rotation
%
% Example
%   cs1 = crystalSymmetry('321')
%   cs2 = crystalSymmetry('432')
%   oR = fundamentalRegion(cs1,cs2)
%   plot(oR)
%
%   % connect to vertices of the fundamental region
%   f = fibre(oR.V(1),oR.V(2))
%
%   % determine some orientations along the fibre
%   o = f.orientation
%
%   % plot the line
%   hold on
%   line(o,'color','r','linewidth',2)
%   hold off
%
% See also
% 

[varargout{1:nargout}] = plot(reshape(rot,[],1),'all','edgecolor',...
  get_option(varargin,{'color','linecolor'},'k'),'Marker','none',varargin{:});


