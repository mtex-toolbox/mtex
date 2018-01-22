function h = quiver(sVF,varargin)
% quiver spherical vector field
%
% Syntax
%   quiver3(sVF)
%
% See also
%   S2VectorField/plot
%

% plot the function values
h = plot(sVF,varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
