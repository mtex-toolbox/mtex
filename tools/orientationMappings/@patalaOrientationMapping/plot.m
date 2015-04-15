function plot(oM,varargin) 
% plot colorbar with patala misorientation colorcoding

% make new plot
% TODO
mtexFig = newMtexFigure(varargin{:});

% get sections
if check_option(varargin,'omega')
  omega = get_option(varargin,'omega');
else
  omega = (5:10:180)*degree;
  omega(omega>oM.CS1.maxAngle) = [];  
end
sR = oM.CS1.Laue.fundamentalSector;

for i = 1:length(omega)
  
  if i>1, mtexFig.nextAxis; end
  
  S2G = plotS2Grid(oM.CS1.Laue.fundamentalSector('angle',omega(i)),varargin{:});
  
  mori = orientation('axis',S2G,'angle',omega(i));
  
  rgb = oM.orientation2color(mori);
 
  % plot boundary
  plot(sR,'parent',mtexFig.gca,'TR',[int2str(omega(i)./degree),'^\circ'],...
    'color',[0.8 0.8 0.8],'doNotDraw');
 
  % rescale the figures according to actual volume
  x = get(mtexFig.gca,'xLim');
  y = get(mtexFig.gca,'yLim');
  x = x .* sin(oM.CS1.maxAngle/2) / sin(omega(i)/2);
  y = y .* sin(oM.CS1.maxAngle/2) / sin(omega(i)/2);
  xlim(mtexFig.gca,x);
  ylim(mtexFig.gca,y);
    
  hold on
  %plot(oM.CS1.fundamentalSector(omega(i)),'parent',mtexFig.gca,'color','k');  
  S2G.surf(rgb,'parent',mtexFig.gca,varargin{:},'doNotDraw');
  hold off
end

mtexFig.drawNow;

end

