function h = plot(sF, varargin)
% plot spherical Function
%
% Syntax
%   plot(sF)
%
% Flags
%  contourf - sF as filled contours
%  contour  - sF as contours
%
% See also
%   S2Fun/contour S2Fun/contourf S2Fun/pcolor S2Fun/plot3d
%

h = plot@S2Fun(sF, varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
