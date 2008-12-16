%% EBSD Grains
%
% till yet MTEX supports only basic grain analyis functions. If spatial 
% data is availible for given orientations, in commen a grain is defined as
% a region of spatial neighboured orientations, where each angle between
% neighbourhood orientations is lower than a given threshold angle.
% Since there are several measure grid types, spatial relations are
% determined through a voronoi diagram.

%% Segmentation
% First import some EBSD data:
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'], ...
  'interface','generic', 'Bunge', ...
  'layout', [5 6 7], 'Phase', 2, 'xy', [3 4]);
plot(ebsd)

%%
% and than let us make a segmentation
ebsd = segment(ebsd);
%%
% and plot the result of the segmentation, where each grain is assigned a
% random color
plot(ebsd,'grains')

%% Working with Grains
% with the
% <matlab:%20web([docroot%20'/techdoc/creating_plots/f4-44221.html']) Data
% Cursor> mode we can explore the grainid, however we can now select single
% grains by an id, 
grains(ebsd,3636)
%%
% or cut the ebsd object into ebsd grains
ebsd_grains = grains(ebsd);
%%
% where now we access a grain through
biggest_grain = find(max(length(ebsd_grains)) == length(ebsd_grains));
ebsd_grains(biggest_grain)
plot(ebsd_grains(biggest_grain),'white')

%% 
% Now let us take a look onto the grain size:
gs = length(ebsd_grains);
ugs = unique(gs);
gc = histc(gs,ugs);

close; figure('position',[100 100 600 250]);
subplot(1,2,1)
loglog( ugs, gc);
xlabel('grain size'); ylabel('occurrence');

subplot(1,2,2)
semilogx( ugs,(gc.*ugs)/size(ebsd,2),'.') 
xlabel('grain size'); 
ylabel('volume %');
set(gcf,'color','w')

%% ODF Calculation
% Now we can compute the ODF of a single grain
odf = calcODF(ebsd_grains(biggest_grain))
close; plotpdf(odf,[Miller(1,0,0); Miller(1,1,0)],'reduced');

%%
% or select various grains after given criterias, e.g largest grains of a
% phase
ebsd_grains = ebsd_grains(gs' > 2*max(gs)/mean(gs) & get(ebsd_grains,'phase') == 1);
close; plot(ebsd_grains,'white')
%%
% however we can treat several grains as one by making a union.
odf = calcODF(ebsd_grains,'union',1:numel(ebsd_grains))
close; plotpdf(odf,[Miller(1,0,0); Miller(1,1,1)],'reduced');
