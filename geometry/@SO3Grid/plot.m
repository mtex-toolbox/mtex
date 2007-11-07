function plot(SO3G,varargin)
% vizualize SO3Grid
%
%% Input
%  SO3G - @SO3Grid
%
%% Options
%  RODRIGUEZ  - plot in rodriguez space
%  distmatrix - plot distmatrix

if check_option(varargin,'RODRIGUEZ')
	r = quat2rodriguez(SO3G.Grid);

	scatter3(getx(r),gety(r),getz(r));

else

  colororder = ['b','g','r','c','m','k','y'];
  v = [xvector,yvector,zvector];
  
  for i = 1:numel(v)

    plot(S2Grid(SO3G.Grid.*v(i)),varargin{:},'dots',...
      'color',colororder(1+mod(i-1,length(colororder))));
    hold on
  end
  
  hold off  
  

end


% 	if length(SO3G) >= 700
% 		error('Grid is to large')
% 	end
% 
% 	M = distMatrix(SO3G.Grid.',SO3G.Grid);
% 	pcolor(M);
% 	axis equal tight
% 	hold on
% 	grid off
% 	colorbar;
% 	if GridLength(SO3G) > 100
% 		shading interp;
% 	end
% 	hold off
% 	M = M + 5*eye(size(M));
% 	disp(min(min(M)));