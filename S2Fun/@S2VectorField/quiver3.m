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

% plot an empty sphere as background
plotEmptySphere;

% plot the function values
[varargout{1:nargout}] = plot(sVF,'3d',varargin{:});

end
