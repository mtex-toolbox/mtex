function prepareMTEXplot(X,Y)

grid on
axis equal
set(gca,'Layer','top')

if nargin == 2  
  axis ([min(X) max(X) min(Y) max(Y)]);
else
  axis tight
end

fixMTEXplot;
