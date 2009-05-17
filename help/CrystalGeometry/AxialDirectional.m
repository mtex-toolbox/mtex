%% Axial and Directional
%
% In MTEX it is possible to consider three dimensional vectors either as
% directions or as axes. By default a the pair of vectors 

v1 = vector3d(1,1,2);
v2 = vector3d(1,1,-2);

%%
% when plotted at the sphere 

close all; figure('position',[100 100 400 300])
plot([v1,v2],'label',{'v_1','v_2'})

%%
% occurs both on the upper and on the lower hemisphere. In order to treat
% these vectors as axes one has to apply the keyword *axial*. 

plot([v1,v2],'label',{'v_1','v_2'},'axial')

%%
% Now the direction $v_2$ is identified with the direction -$v_2$ which
% plotts at the upper hemispher.

%% The Angle between Directions and Axis
%
% In general there is also a difference 

angle(v1,v2) / degree

%%

angle(v1,v2,'axial') / degree

%% Axial Symmetry in Experimental Pole Figures
%
% Due to Friedels law experimental pole figures are allways axial data. One
% consequence of this fact is that MTEX plots pole figure data allway on
% the upper hemisphere

% crystal and specimen symmetry
cs = symmetry('-3m',[1.4,1.4,1.5]);
ss = symmetry('triclinic');

% specify file names
fname = {[mtexDataPath '/dubna/Q(10-10)_amp.cnv']};

% specify crystal directions
h = {Miller(1,0,-1,0,cs)};

% import pole figure data
pf = loadPoleFigure(fname,h,cs,ss);

% plot pole figure data
plot(pf)

%%
% Moreover if you annotate a certain direction to pole figure data, it is
% always interpreted as an axis, i.e. projected to the upper hemisphere if
% necessary

annotate(vector3d(1,0,-1),'labeled')

%% Axial Symmetry in Recalculated Pole Figures
%
% However, in the case of pole figures calculated from an ODF axial
% symmetry is in general not present.

% some prefered orientation
q = euler2quat(20*degree,30*degree,0);

% define an unimodal ODF
odf = unimodalODF(q,cs,ss);

% plot pole figures
plotpdf(odf,Miller(1,2,2),'position',[100 100 400 200])

%%
% Hence, if one wants to compare calculated pole figures with experimental
% one, one has to add axial symmetry.

plotpdf(odf,Miller(1,2,2),'axial')

%% Axial Symmetry in inverse Pole Figures
% 
% The same reasoning as above holds true for inverse pole figures. I we
% look at complete, inverse pole figures they do not posses axial symmetry
% in general

plotipdf(odf,yvector,'position',[100 100 400 200],'complete')

%%
% However, if we add the keyword axial, axial symmetry is enforced.

plotipdf(odf,yvector,'axial','complete')

%%
% Notice how MTEX, automatically reduces the fundamental region of inverse
% pole figures in the case that axial symmetry is present.

plotipdf(odf,yvector,'position',[100 100 400 200])

plotipdf(odf,yvector,'axial')


%% EBSD Colocoding
%
% Axial symmetry effects also the colocoding of ebsd plots. Lets first
% import some data.

% crystal symmetry
% specify crystal and specimen symmetry
cs = symmetry('m-3m');

% file name
fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

% import data
ebsd = loadEBSD(fname,cs,ss,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'Mad' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],...
  'ignorePhase', [0 2], 'Bunge');

%%
% Now we plot these data with a colorcoding according to the inverse
% (1,0,0) pole figure. Here no axial symmetry is present.

close all
plot(ebsd)
colorbar

%%
% Compare to the result when axial symmetry is introduced.


plot(ebsd,'axial')
colorbar
