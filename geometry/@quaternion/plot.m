function plot(q,varargin)
% plot function

if numel(q) == 1
  
  v = [xvector,yvector,zvector];
  plot(q*v,'data',...
    {char(v(1),'Latex'),char(v(2),'Latex'),char(v(3),'Latex')},...
    varargin{:});
  
else
  
  v = [xvector,yvector,zvector];
  
  for i = 1:numel(v)

    plot(S2Grid(q.*v(i)),varargin{:},'dots');
    hold all
  end
  
  hold off  
end
