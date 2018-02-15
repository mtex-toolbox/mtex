function h = pcolor(sF,varargin)
% spherical contour plot
%
% Syntax
%   pcolor(sF)
%
% Input
%  sF - @S2Fun
%
% See also
% S2Fun/plot S2Fun/contourf
%

% plot the function values
h = plot(sF,'pcolor',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
