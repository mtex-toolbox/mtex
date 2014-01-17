%% Modify Pole Figure Data
% Explains how to manipulate pole figure data in MTEX. 
%
%% Open in Editor
%
%% Contents
%
%% Import diffraction data
%
% Let us load some data and plot them.

mtexdata geesthacht

% plot imported polefigure
plot(pf)


%% Splitting and Reordering of Pole Figures
% As we can see the first and the third pole figure complete pole figures
% and the second and the fourth pole figure contain some values for
% background correction. Let us therefore split the pole figures into
% these two groups. 

pf_complete = pf([1 3]);
pf_background= pf([2 4]);

%%
% Actually it is possible to work with pole figures as with simple numbers.
% E.g. it is possible to add / subtract pole figures. A superposition of
% the first and the third pole figure can be written as

2*pf(1) + 3*pf(3)


%% Correct pole figure data
%
% In order to correct pole figures for background radiation and
% defocussing one can use the command 
% <PoleFigure.correct.html correct>. In our case the syntax is

pf = correct(pf_complete,'background',pf_background);
plot(pf)

%% Normalize pole figures
%
% Sometimes people want to have normalized pole figures. In the case of
% compete pole figures this can be simply archived using the command
% <PoleFigure.normalize.html normalize> 

pf = normalize(pf);
plot(pf)

%%
% However, in the case of incomplete pole figures it is well known, that
% the normalization can only by computed from an ODF. Therefore, one has to
% proceed as follows.

% compute an ODF from the pole figure data
odf = calcODF(pf);

% and use it for normalization
pf = normalize(pf,odf);

plot(pf)


%% Modify certain pole figure values
% 
% As pole figures are usaly experimental data they may contain outliers. In
% order to remove outliers from pole figure data one can use the functions
% <PoleFigure.findOutlier.html findOutlier> and <PoleFigure.delete.html
% delete>. Here a simple example:

% get the polar angle of the pole figure data
theta = get(pf,'theta');

% and set some measurements to a large value 
pf_outlier = set(pf,'intensities',3.5,...
  theta>35*degree & theta<40*degree)

% now we an outlier in the center of both pole figures
plot(pf_outlier)

%%
% lets find and remove these outliers
outlier = findOutlier(pf_outlier);
pf_outlier = delete(pf_outlier,outlier);

% plot the corrected pole figures
plot(pf_outlier)


%% Remove certain measurements from the data
% In the same way one can manipulate and delete pole figure data by any
% criteria. Of particular importance are the functions <PoleFigure.set.html
% set> and <PoleFigure.get.html get> which allows to address the raw pole
% figure data directly. Lets, e.g. cap all values that are larger then 500.


% find those values
large_values = get(pf,'intensities') > 500;

% cap the values in the pole figures
pf_corrected = set(pf,'intensities',500,large_values);

plot(pf_corrected)


%% Rotate pole figures
% Sometimes it is neccasary to rotate the pole figures. In order to do this
% with MTEX on has first to define a rotation, e.e. by

% This defines a rotation around the x-axis about 100 degree
rot = rotation('axis',xvector,'angle',100*degree);

%%
% Second, the command <PoleFigure_rotate rotate> can be used to rotate the
% pole figure data.
pf_rotated = rotate(pf,rot);
plot(pf_rotated,'antipodal')



