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
plotNodes = equispacedS2Grid('resolution',4*degree,'no_center',varargin{:});

% evaluate the function on the plotting grid
values = sF.eval(plotNodes);

% some default plotting settings
varargin = ['color', 'k', 'arrowSize', 300/(max(norm(values))*length(plotNodes)) varargin];
if check_option(varargin,'complete')
  varargin = [varargin,{'removeAntipodal'}];
end

% plot the function values
h = quiver(plotNodes,values,varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
