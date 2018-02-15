function h = quiver(sAF,varargin)
% quiver spherical axis field
%
% Syntax
%   quiver3(sAF)
%
% See also
%   S2VectorField/plot
%

% plot the function values
h = plot(sAF,varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
