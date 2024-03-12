function h = plotSlipSystem(cS, sS, varargin)
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

h = plotInnerFace(cS,sS.n,'faceAlpha',0.5,varargin{:});

V = cS.innerFace(sS.n); 
m = norm(V(2:end)+V(1:end-1))./2;

d = sS.b;
d = normalize(d) * min(m);
h = [h,arrow3d(d,varargin{:})];

if nargout == 0, clear h; end


end