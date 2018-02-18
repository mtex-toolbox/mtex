function h = plot3d(sF,varargin)
% plot spherical Function
%
% Syntax
%   plot3d(sF)
%
% See also
%   S2Fun/contour S2Fun/contourf S2Fun/pcolor S2Fun/plot
%

% plot the function values
h = plot(sF,'3d',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
