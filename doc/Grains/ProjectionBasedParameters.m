%% Projection Based Shape Parameters
%
%%
% In this section we discuss shape parameters grains that depend on one
% dimensional projections. Lets start with a overview of all such
% parameters.
%
% || <grain2d.calliper.html |grains.calliper|>  || calliper or Feret diameter ||
% || <grain2d.diameter.html |grains.diameter|>  || diameter in |grains.scanUnit|  || 
% || <grain2d.paror.html |grains.paror|>  || cummulative particle projection function  || 
%
% In order to demonstrate these parameters we first import a small sample
% data set.


% load sample EBSD data set
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed');

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

% smooth them
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off


%% Direct Shape Paramters - size, area, diameter, perimeter and calliper
%
% The most well known projection based paramter  is the
% <grain2d.diamter.html |diameter|> which refers to the longest distance
% between any two boundary points and is given in µm.

grains(9).diameter

%%
% The diameter is a special case of the <grain2d.caliper.html |caliper|> or
% Feret diameter of a grain. By definition the caliper is the length of a
% grain when projected onto a line. Hence, the length of the longest
% projection is coincides with the diameter, while the quotient between
% longest and shortest projection gives an indication about the shape of
% the grain

grains(9).calliper('longest')
grains(9).calliper('shortest')

%%
% TODO: some more to explain


