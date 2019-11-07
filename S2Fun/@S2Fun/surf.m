function surf(sF,varargin)


[mtexFig,isNew] = newMtexFigure(varargin{:});

S2G = plotS2Grid('resolution',5*degree,varargin{:});
  
d = reshape(sF.eval(S2G),size(S2G, 1), size(S2G, 2), []);
    
if isa(d,'double') && ~isreal(d), d = real(d);end
  
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end
  [x,y,z] = double(abs(d(:, :, j)).*S2G);
    
  h = surf(x,y,z,'parent',mtexFig.gca, varargin{:});
  set(h,'CData',d(:, :, j))
  axis equal
  optiondraw(h,varargin{:});
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
