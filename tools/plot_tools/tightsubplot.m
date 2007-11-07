function a = tightsubplot(y,x,n)
% subplots that fill the whoole figure

a = subplot('position',[(mod(n-1,x))/x,1-0.995*fix(1+(n-1)/x)/y,1/x,0.995/y]);
s = get(gcf,'position');
s(3) = (s(4))*x/y;
set(gcf,'position',s);
