mtexFig = mtexFigure;

ax = mtexFig.nextAxis;

x = linspace(0,pi);
plot(sin(x),'parent',ax);

ax = mtexFig.nextAxis;
plot(cos(x),'parent',ax);

mtexFig.drawNow
