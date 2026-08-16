function varargout = quiver3(sVF,varargin)
% 3-dimensional quiver spherical vector field
%
% Syntax
%   quiver3(sVF)
%
% Options
%  normalized - normalize vectors
%  arrowSize  - arrow size
%  maxHeadSize - head size

% See also
% S2VectorField/plot
%

% the background sphere and the arrows have to accumulate into the same
% axes, so the hold spans both - plotEmptySphere used to end with
% hold(ax,'on') and leave the axes held for its caller, but it takes a
% guard of its own now, which is released the moment it returns. Without a
% hold here the plot below starts a fresh axes and the sphere is gone.
% @vector3d/scatter3d holds the same way
ax = get_option(varargin,'parent',gca);
hG = holdOn(ax); %#ok<NASGU>

% plot an empty sphere as background
plotEmptySphere('parent',ax);

% plot the function values
[varargout{1:nargout}] = plot(sVF,'3d',varargin{:});

end
