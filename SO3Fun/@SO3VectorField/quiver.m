function varargout = quiver(SO3VF,varargin)
% quiver rotational vector field
%
% Syntax
%   quiver3(sVF)
%
% Options
%  normalized - normalize vectors
%  arrowSize  - arrow size
%  maxHeadSize - head size

% See also
%   S2VectorField/plot
%

% plot the function values
[varargout{1:nargout}] = plot(SO3VF,varargin{:});

end
