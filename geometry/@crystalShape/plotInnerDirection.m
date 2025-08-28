function h = plotInnerDirection(cS, d, varargin)
%
% Syntax
%   d = Miller(1,0,1,'uvw',cs)
%   plotInnerFace(cS,d,'faceColor','blue','faceAlpha',0.5,'edgeColor','k') 
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
% cS = crystalShape.olivine;
% N  = Miller(1,0,1,'hkl',cS.CS);
%   
% plot(cS,'faceAlpha',0.2,'colored')
% hold on
% plotInnerFace(cS,N,'faceColor','blue','DisplayName','(101)')
% plotInnerFace(cS,Miller(0,1,1,cS.CS),'faceColor','red','DisplayName','(011)')
% hold off
%

V = cS.innerFace(d.perp); 
m = norm(V(2:end)+V(1:end-1))./2;

d = normalize(d) * min(m);
h = arrow3d(d,varargin{:});

if nargout == 0, clear h; end

end
