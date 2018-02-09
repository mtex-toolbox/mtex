function h = contour(sF,varargin)
% spherical contour plot
%
% Syntax
%   contour(v,data)
%
% Input
%   sF - @S2Fun
%
% Options
%   contours - number of contours
%
% See also
%   S2Fun/plot S2Fun/contourf
%

% plot the function values
h = plot(sF,'contour',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
