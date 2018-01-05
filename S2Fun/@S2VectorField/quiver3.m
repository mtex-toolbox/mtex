function h = quiver3(sF,varargin)
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
varargin = ['color', 'k', 'maxHeadSize', 0, 'arrowSize', 0.5*plotNodes.resolution/max(norm(values)) varargin];
if check_option(varargin,'complete')
  varargin = [varargin,{'removeAntipodal'}];
end

% plot the function values
h = quiver3(plotNodes,values,varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
