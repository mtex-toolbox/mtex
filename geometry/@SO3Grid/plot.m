function plot(SO3G,varargin)
% vizualize SO3Grid
%
%% Input
%  SO3G - @SO3Grid
%
%% Options
%  RODRIGUEZ  - plot in rodriguez space

if check_option(varargin,'RODRIGUEZ') || sum(GridLength(SO3G)) > 50
  
  for i = 1:length(SO3G)
    r = quat2rodriguez(SO3G(i).Grid);

    scatter3(getx(r),gety(r),getz(r)); 
    hold all
  end
  hold off
  
else

  v = [xvector,yvector,zvector];
  
  for i = 1:numel(v)

    plot(S2Grid(SO3G.Grid.*v(i)),varargin{:},'dots');
    hold all
  end
  
  hold off  
  
end
