function h = contourf(sF,varargin)
% spherical filled contour plot
%
% Syntax
%   contourf(sF)
%
% Input
%  sF - @S2Fun
%
% Options
%  contours - number of contours
%
% See also
%   S2Fun/plot S2Fun/contour
%

% plot the function values
h = plot(sF,'contourf',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
