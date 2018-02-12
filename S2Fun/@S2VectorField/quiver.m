function varargout = quiver(sVF,varargin)
% quiver spherical vector field
%
% Syntax
%   quiver3(sVF)
%
% Options
%  normalized - normalize vectors
%  arrowSize
%  maxHeadSize

% See also
%   S2VectorField/plot
%

% plot the function values
[varargout{1:nargout}] = plot(sVF,varargin{:});

end
