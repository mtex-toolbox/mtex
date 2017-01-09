function h = plot(sF,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%

% generate a grid where the function will be plotted
plotNodes = plotS2Grid(varargin{:});

% evaluate the function on the plotting grid
values = sF.eval(plotNodes);

% plot the function values
h = plot(plotNodes,values,'contourf',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
