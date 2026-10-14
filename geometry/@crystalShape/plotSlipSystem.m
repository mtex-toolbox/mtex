function h = plotSlipSystem(cS, sS, varargin)
% plot a slip system into a crystal shape, its plane as an inner face and its Burgers vector as an arrow
%
% Syntax
%
%   h = plotSlipSystem(cS,sS,'faceColor','blue') % slip plane and slip direction of sS
%
% Input
%  cS - @crystalShape
%  sS - @slipSystem
%
% Output
%  h - handle to the graphics object
%
% Options
%  PatchProperty - <https://mathworks.com/help/matlab/ref/matlab.graphics.primitive.patch-properties.html all matlab patch properties>
%
% Example
%
%   cs = crystalSymmetry.load('Mg-Magnesium.cif');
%   cS = crystalShape.hex(cs)
%   sS = [slipSystem.pyramidal2CA(cs), ...
%         slipSystem.pyramidalA(cs)];
%
%   plot(cS,'faceAlpha',0.2)
%   hold on
%   plot(cS,sS(2),'faceColor','blue')
%   plot(cS,sS(1),'faceColor','red')
%   hold off
%
% See also
% CrystalShapes
%

h = plotInnerFace(cS,sS.n,'faceAlpha',0.5,varargin{:});

V = cS.innerFace(sS.n); 
m = norm(V(2:end)+V(1:end-1))./2;

d = sS.b;
d = normalize(d) * min(m);
h = [h,arrow3d(d,varargin{:})];

if nargout == 0, clear h; end


end