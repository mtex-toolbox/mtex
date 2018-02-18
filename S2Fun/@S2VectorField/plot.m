function h = plot(sVF,varargin)
% plot spherical vector field
%
% Syntax
%   plot(sVF)
%
% Options
%  normalized - normalize vectors
%  arrowSize
%  maxHeadSize
%
% See also
% S2VectorField/quiver3
%  

% generate a grid where the function will be plotted
plotNodes = equispacedS2Grid('resolution',10*degree,'no_center',varargin{:});

% evaluate the function on the plotting grid
values = sVF.eval(plotNodes);

if check_option(varargin,'normalized'), values = values.normalize; end

% some default plotting settings
varargin = ['color', 'k', 'arrowSize', ...
  0.5*plotNodes.resolution/max(norm(values)) varargin];
if check_option(varargin,'complete')
  varargin = [varargin,{'removeAntipodal'}];
end

% plot the function values
if check_option(varargin, '3d')
  varargin = ['maxHeadSize', 0, varargin];
  h = quiver3(plotNodes,values,varargin{:});
else
  h = quiver(plotNodes,values,varargin{:});
end

% remove output if not required
if nargout == 0, clear h; end

end
