function plot(q,varargin)
% plot function

if numel(q) == 1
  
  v = [xvector,yvector,zvector];
  plot(q*v,'data',...
    {char(v(1),'Latex'),char(v(2),'Latex'),char(v(3),'Latex')},...
    varargin{:});
  
else
  
%  plot(SO3Grid(q),varargin{:});

  colororder = ['b','g','r','c','m','k','y'];
  v = [xvector,yvector,zvector];
  
  for i = 1:numel(v)

    plot(S2Grid(q.*v(i)),varargin{:},'dots',...
      'color',colororder(1+mod(i-1,length(colororder))));
    hold on
  end
  
  hold off  
end
