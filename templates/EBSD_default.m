%% Default template
%% Visualize the Data

plot(ebsd)


%% Calculate an ODF

odf = calcODF(ebsd)

%% Detect grains

%segmentation angle
segAngle = 10*degree;

[grains ebsd] = calcGrains(ebsd,'angle',segAngle);

%% Orientation of Grains

plot(grains)
