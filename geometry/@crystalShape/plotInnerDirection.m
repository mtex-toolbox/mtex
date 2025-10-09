function h = plotInnerDirection(cS, d, varargin)
%
% Syntax
%   d = Miller(1,0,1,'uvw',cs)
%   plotInnerDirection(cS,d,'faceColor','blue','faceAlpha',0.5,'edgeColor','k') 
%
% Input
%  cS - @crystalShape
%  d  - @Miller crystal direction
%
% Output
%  h - handle to the graphics object
%
% Options
%  PatchProperty - see documentation of patch objects for manipulating the apperance, e.g. 'EdgeColor'
%
% Example
%
%   % define and plot a crystal shape
%   cS = crystalShape.olivine;
%   plot(cS,'faceAlpha',0.2,'colored')
%   
%   % define and plot a crystal plane and a crystal direction
%   d = Miller(1,0,1,'uvw',cS.CS); 
%   n = Miller(1,0,-1,'hkl',cS.CS); 
%   hold on
%   plotInnerFace(cS,n,'faceColor','red','DisplayName','$\{10\bar1\}$','faceAlpha',0.5)
%   plotInnerDirection(cS,d,'faceColor','blue','arrowWidth',0.05,'DisplayName','$\langle 101 \rangle$')
%   hold off
%
% See also
% crystalShape/plotSlipSystem
%

V = cS.innerFace(d.perp); 
m = norm(V(2:end)+V(1:end-1))./2;

d = normalize(d) * min(m);
h = arrow3d(d,varargin{:});

if nargout == 0, clear h; end

end
