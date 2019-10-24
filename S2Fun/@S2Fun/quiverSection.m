function quiverSection(sF,sVF,sec,varargin)
%
% Syntax
%   quiverSection(sF,v,vector3d.Z)
%   quiverSection(sF,sVF,vector3d.Z)
%   quiverSection(sF,v,vector3d.Z,pi/3)
%
% Input
%  sF  - @S2Fun
%  v   - @vector3d 
%  sVF - @S2VectorField
%
% Flags
%  normalized - normalize vectors before plotting
%


[mtexFig,isNew] = newMtexFigure(varargin{:});

omega = linspace(0,2*pi,36);
  
if nargin > 3 && isnumeric(varargin{1})
  eta = varargin{1};
else
  eta = pi/2;
end

S2 = axis2quat(sec,omega) * axis2quat(orth(sec),eta) * sec;
if isa(sVF,'function_handle')
  v = sVF(S2);
else
  v = sVF.eval(S2);
end
v = v(:);
if check_option(varargin,'normalized'), v = v.normalize; end
    
d = reshape(sF.eval(S2),length(S2), []);

h = [];
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end

  x = d(:, j).*S2.x;
  y = d(:, j).*S2.y;
  z = d(:, j).*S2.z;
  
  if v.antipodal
    opt = {'showArrowHead','off'};
    hh = quiver3(x,y,z,-v.x,-v.y,-v.z,'parent',mtexFig.gca,opt{:});
    set(get(get(hh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h = [h,hh]; %#ok<AGROW>
  else
    opt = {};
  end
  
  h = [h,quiver3(x,y,z,v.x,v.y,v.z,'parent',mtexFig.gca,opt{:})];
  
  
end
optiondraw(h,varargin{:});
view(mtexFig.gca,squeeze(double(sec)));
set(mtexFig.gca,'dataAspectRatio',[1 1 1]);

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
