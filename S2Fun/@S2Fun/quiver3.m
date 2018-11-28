function h = quiver3(sF,sVF,varargin)
% a quiver plot on top of a surface plot
%
% Syntax
%
%   surf(sF)
%   hold on
%   quiver3(sF,sVF)
%   hold off
%
% Input
%
% sF - @S2Fun
% SVF - @S2VectorField
% SAF - @S2AxisField
%
% Output
%
% See also
% S2Fun/surf S2VectorField/quiver3 vector3d/quiver3

% generate a grid where the function will be plotted
plotNodes = equispacedS2Grid('resolution',10*degree,'no_center',varargin{:}).';
  
values = sF.eval(plotNodes);
    
if isa(values,'double') && ~isreal(values), values = real(values);end
  
% evaluate the function on the plotting grid
vec = sVF.eval(plotNodes);

if check_option(varargin,'normalized'), vec = vec.normalize; end

% some default plotting settings
varargin = ['color', 'k', 'arrowSize', ...
  mean(values)*0.5*plotNodes.resolution/max(norm(vec)) varargin];

% plot the function values

varargin = ['maxHeadSize', 0, varargin];
h = quiver3(values .* plotNodes,vec,varargin{:});

% remove output if not required
if nargout == 0, clear h; end
