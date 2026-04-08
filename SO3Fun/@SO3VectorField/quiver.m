function varargout = quiver(SO3VF,varargin)
% quiver rotational vector field
%
% Syntax
%   quiver(SO3VF)
%
% Options
%  normalized - normalize vectors
%  arrowSize  - arrow size
%  maxHeadSize - head size

% See also
% SO3VectorField/plot
%

% plot the function values
[varargout{1:nargout}] = plot(SO3VF,varargin{:});

end
