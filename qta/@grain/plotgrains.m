function plotgrains(grains,varargin)
% plot the grain boundaries
%
%% Syntax
%  plotgrains(grains)
%  plotgrains(grains,LineSpec,...)
%  plotgrains(grains,'PropertyName',PropertyValue,...)
%
%% Input
%  grains - @grain
%
%% Options
%  NOHOLES  -  plot grains without holes
%  HULL / CONVHULL - plot the convex hull of grains
%
%% See also
% grain/plot grain/plotellipse grain/plotsubfractions

noholes = check_option(varargin,'noholes');
convhull = check_option(varargin,{'hull','convhull'});
 varargin = delete_option(varargin,{'noholes','hull','convhull' },0);

%%
newMTEXplot;


%%
set(gcf,'renderer','opengl')

ih = ishold;

p = polygon(grains)';

if convhull
  for k=1:length(p)
    xy = p(k).xy;
    K = convhulln(p(k).xy);
    p(k).xy = [xy([K(:,1); K(1,1)],:); NaN NaN];
  end  
end

xy = cell2mat(arrayfun(@(x) [x.xy ; NaN NaN],p,'UniformOutput',false));
X = xy(:,1);
Y = xy(:,2);

[X,Y, lx,ly] = fixMTEXscreencoordinates(X,Y,varargin);

plot(X(:),Y(:),varargin{:});
xlabel(lx); ylabel(ly);

%holes
if ~noholes & ~convhull
  bholes = hasholes(grains);
  
  if any(bholes)
    if ~ih, hold on, end
    ps = polygon(grains(bholes))';

    xy = cell2mat(arrayfun( @(x) ...
      cell2mat(cellfun(@(h) [h;  NaN NaN], x.hxy,'uniformoutput',false)') ,...
      ps,'uniformoutput',false));

    X = xy(:,1);
    Y = xy(:,2);
    [X,Y] = fixMTEXscreencoordinates(X,Y,varargin);
    plot(X(:),Y(:),varargin{:});
    if ~ih, hold off, end
  end
end
%%

fixMTEXplot;
