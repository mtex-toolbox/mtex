function h = surf(sF,varargin)

% rescale the function to be with 0.5 and 2
if isscalar(sF) && sF.isReal
  
  a = min(sF);
  b = max(sF);

  if b > a    
    sF =  (sF - mean(sF)) ./ (b-a) +1;
  end

end

[mtexFig,isNew] = newMtexFigure(varargin{:});

S2G = plotS2Grid('resolution',5*degree,varargin{:});
  
d = reshape(sF.eval(S2G),size(S2G, 1), size(S2G, 2), []);
    
if isa(d,'double') && ~isreal(d), d = real(d);end
  
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end
  [x,y,z] = double((abs(d(:, :, j))).*S2G);
    
  h(j) = optiondraw(surf(x,y,z,'parent',mtexFig.gca), varargin{:});
  set(h,'CData',d(:, :, j))
  axis equal
  optiondraw(h,varargin{:});
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end

if nargout == 0, clear h; end