function h = plot(sAF,varargin)
% plot spherical axis field
%
% Syntax
%   plot(sAF)
%
% See also
%   S2VectorField/quiver3
%

% generate a grid where the function will be plotted
plotNodes = equispacedS2Grid('resolution',10*degree,'no_center',varargin{:});

% evaluate the function on the plotting grid
values = sAF.eval(plotNodes);

% some default plotting settings
varargin = ['color', 'k', 'maxHeadSize', 0, varargin];
if check_option(varargin,'complete')
  varargin = [varargin,{'noAntipodal'}];
end

% plot the function values
if check_option(varargin, '3d')
  h = quiver3(plotNodes,values,varargin{:});
else
  h = quiver(plotNodes,values,varargin{:});
end

% remove output if not required
if nargout == 0, clear h; end

end
