function h = plotInnerFace(cS, N, varargin)
%
% Syntax
%   N = Miller(1,0,1,'hkl',cs)
%   plotInnerFace(cS,N,'faceColor','blue','faceAlpha',0.5,'edgeColor','k') 
%
% Input
%  cS - @crystalShape
%  N  - @Miller lattice plane
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

% starting and end points of all vertices
v1 = cS.V(cS.E(:,1));
v2 = cS.V(cS.E(:,2));

% compute intersections between edges and plane normal
V = lineIntersect(v1,v2,N,0);
V = V(~isnan(V));

% convex hull of vertices - we do this in 2d to avoid triangulation
rot = rotation.map(N,zvector);
VPlane = rot .* V;
T = convhull([VPlane.x,VPlane.y]);

% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});

h = optiondraw(patch('Faces',T.','Vertices',V.xyz,'edgeColor','black',...
  'parent',get_option(varargin,'parent',mtexFig.gca)),varargin{:});

if isNew, drawNow(mtexFig,varargin{:}); end

if nargout == 0, clear h; end

end
