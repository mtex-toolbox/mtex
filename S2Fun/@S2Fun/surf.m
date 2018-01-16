function surf(sF,varargin)


[mtexFig,isNew] = newMtexFigure(varargin{:});

[x,y,z] = sphere(90);
S2 = vector3d(x,y,z);
%   S2 = S2Grid('regular','resolution',120varargin{:});
  
d = reshape(sF.eval(S2),size(S2));
    
if isa(d,'double') && ~isreal(d), d = real(d);end
  
[x,y,z] = double(abs(d).*S2);
  
h = surf(x,y,z);
set(h,'CData',d)
axis equal
optiondraw(h,varargin{:});

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
