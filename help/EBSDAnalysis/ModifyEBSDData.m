%% Manipulation of Individual Orientation Data
%
%% Open in Editor
%
%% Abstract
% MTEX offers some routines for manipulation of EBSD or grain objects, this
% section gives a short overview over the most helpfull commands.
%
%% Contents
%
%%
% Let us first import some standard EBSD data with a [[loadaachen.html,script file]]

loadaachen;

%%
% and model some grains

[grains, ebsd] = segment2d(ebsd);

%% Object Manipulation
% In general for every object there exists a *set* and *get* command to
% retrive object properties, taking a look on the command window one may
% find several properties like bands, bc, bs and so on

ebsd

%%
%

o  = get(ebsd,'orientations')
xy = get(ebsd,'xy');
b  = get(ebsd,'mad');

%%
% naturally it behaves as well with grains, however we can set and get
% properties

ebsd = set(ebsd,'property','property')
get(ebsd,'property')

%%
% that is the way of object manipulation. Nontheless there are some more
% sophisticated routines, e.g. simply extracting a new EBSD object or to
% rotate the EBSD Specime concurrent to PoleFigure Measurements

%% Extracting subsets by Indexing
% Another task is [[EBSD_copy.html,copying]] or [[EBSD_delete.html,deleting]]
% some orientations in an EBSD data-set, i.e. we want to get rid of the
% first 10000 measurements, it can be done by giving its linear index 
% in the dataset

ebsd_deleted = delete(ebsd, 1:10000)
ebsd_copied  = copy(ebsd, 1:10000)

%%
%
plot(ebsd_deleted)

%%
% 
plot(ebsd_copied)

%%
% or by logical indexing, e.g. falsification of some object property 

x = get(ebsd,'x');

close all;
plot( copy(ebsd, x > 100 & x < 200 ) ,'property','bc')
hold on,
plot( delete(ebsd, x > 100 ) ,'colorcoding','hkl')

%%
% having grains its easier to treat indexing, since each grain is stored in
% a data vector, we can simply give the position directly

grains(1); grains(300:400);

%%
% thus it allows us to index directly, e.g. return the 10 largest grains

[grain_sizes ndx] = sort( grainsize(grains), 'descend' );
grain_selection = grains( ndx(1:10) ) 

%%
%
close all;
plot(grain_selection)

%%
% Futhermore it allows [[matlab:doc cat, concatenation]] of several grain subsets

grain_selection_2 = grains( ndx(30:40) );
grain_selection   = [grain_selection, grain_selection_2]

%%
% taking into account, that every grain owns a [[polygon_index.html,
% polygon]] it allows powerfull selection

grains( area(grains) > 300 )
grains( shapefactor(grains) > 2 )
grains( paris(grains) > 50 )

%% Extracting spatial subsets 
% Subsets of data may be very usefull for analysing something with very
% special respects

%%
% When having *spatially* information, one can select data after its
% location, e.g. by given bounds like a [[polygon_index.html,polygon]] with
% the command [[EBSD_inpolygon.html,inpolygon]]

p = polygon([120 130; 120 100; 200 100; 200 130; 120 130]);
ebsd_of_p = inpolygon(ebsd,p)

%%
%
close all;
plotboundary(grains)
hold on, plot(ebsd_of_p)
hold on, plot(p,'color','r')

%%
% and also grains in a similar same manner
% [[polygon_inpolygon.html,inpolygon]], where the command now returns a
% logical indexing

grain_selection = grains( inpolygon(grains,p) )

%%
% the grains are *[[grain_link.html,linked]]* to its underlaying ebsd data by
% an intrinsic object id, which could be used to select accordingly

ebsd_selection = link( ebsd, grain_selection)

%%
%
close all;
plotboundary(grains)
hold on, plot(ebsd_selection)
hold on, plotboundary(grain_selection,'color','r','linewidth',2)

%%
% so with regard to aboves selected ebsd object we can get its grains in 
% another way

grains_of_p = link(grains, ebsd_of_p)

%% Extracting subsets by orientation
% An other way of selecting data is by an given orientation / rotation. 

rot = rotation('Euler',[-2.5795 -1.8764 -2.0348 -1.6752  1.5785],...
   [ 0.9852  0.4761  0.8748  0.7838  0.5469],...
   [ 2.2687  2.3882  2.3065  2.3701 -2.3617],'ABG');
    
ebsd_by_rot = find(ebsd,rot,5*degree)
grains_by_rot = find(grains,rot,5*degree)

%%
% since we have a assigned a mean orientation for each grain we may expect
% different results 

close all; 
plotboundary(grains)
hold on, plot(ebsd_by_rot)
hold on, plotboundary(grains_by_rot,'color','r')


%% Rotating, Flipping of EBSD Data
% Sometimes its required to edit EBSD Data, e.g. by
% [[EBSD_rotate.html,rotating]] the Sample, or sometimes only the
% orientations

ebsd_rot = rotate(ebsd, 15*degree)
ebsd_rot = rotate(ebsd_rot,rot(4),'keepXY')

close all
plot(ebsd_rot)

%%
% as a consequence, when manipulating the ebsd object, grains have 
% to be modelled again, since they may be not any longer congruent.

%%
% sometimes coordinates are flipped, it can be resolved by using the
% [[EBSD_flipud.html,flipud]] or [[EBSD_fliplr.html,fliplr]]

close all
plot( fliplr( flipud(ebsd) ) )
