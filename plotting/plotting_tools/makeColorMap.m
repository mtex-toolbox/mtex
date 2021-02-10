function makeColorMap(N)

if nargin == 0, N = 24; end

old = get(0,'DefaultAxesColorOrder');

matlab = [[0, 0.4470, 0.7410]; ...
  [0.8500, 0.3250, 0.0980]; ...
  [0.9290, 0.6940, 0.1250]; ... 
  [0.4660, 0.6740, 0.1880];	...
  [0.4940, 0.1840, 0.5560];	...
  [0.3010, 0.7450, 0.9330];	...
  [0.6350, 0.0780, 0.1840]];

old = vega20(20);
ind = [1,4,2,3,10,5];
old(ind,:) = [];
old = [matlab; old];
old([13,18],:) = [];
%old([13],:) = [];

fun = @(m)sRGB_to_OSAUCS(m,true,true);
rgb = maxdistcolor(N,fun,'inc',old, 'Lmin',0.4, 'Lmax',0.95,'CMax',0.6);
setMTEXpref('colors',rgb)


save(fullfile(mtex_path,'plotting','plotting_tools','colors.mat'),'rgb');

end

%%

 %v = vector3d.rand(24);
 %M = 24; plot(v(1:M),ind2color(1:M),'MarkerSize',20,'label',xnum2str(1:M,'cell'))
 
for k = 1:24, text(0,k,int2str(k),'backgroundColor',ind2color(k) ),end
ylim([0,24])
 
 
 
matlab = [[0, 0.4470, 0.7410]; ...
  [0.8500, 0.3250, 0.0980]; ...
  [0.9290, 0.6940, 0.1250]; ...
  [0.4940, 0.1840, 0.5560];	 , ...
  [0.4660, 0.6740, 0.1880];	 , ...
  [0.3010, 0.7450, 0.9330];	 , ...
  [0.6350, 0.0780, 0.1840]]

rgb(1,:) = matlab(1,:);
rgb(4,:) = matlab(2,:);
rgb(2,:) = matlab(3,:);
rgb(21,:) = matlab(4,:);
rgb(3,:) = matlab(5,:);
rgb(10,:) = matlab(6,:);
rgb(5,:) = matlab(7,:);

ind = [1,4,2,21,3,10,5];
rgb(ind,:) = [];
rgb = [matlab;rgb]



setMTEXpref('colors',rgb)

