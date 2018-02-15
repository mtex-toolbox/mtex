function surf(sF,varargin)


[mtexFig,isNew] = newMtexFigure(varargin{:});

[x,y,z] = sphere(90);
S2 = vector3d(x,y,z);
%   S2 = S2Grid('regular','resolution',120varargin{:});
  
d = reshape(sF.eval(S2),size(S2, 1), size(S2, 2), []);
    
if isa(d,'double') && ~isreal(d), d = real(d);end
  
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end
  [x,y,z] = double(abs(d(:, :, j)).*S2);
    
  h = surf(x,y,z,'parent',mtexFig.gca, varargin{:});
  set(h,'CData',d(:, :, j))
  axis equal
  optiondraw(h,varargin{:});
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
