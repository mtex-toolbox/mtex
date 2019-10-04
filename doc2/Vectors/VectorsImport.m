%% Importing Vectors
%
%%
% Large lists of vectors can be imported from a text file by the command

fname = fullfile(mtexDataPath,'vector3d','vectors.txt');
v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'})

%%
% In order to visualize large lists of specimen directions scatter plots

scatter(v,'upper')

%%
% or contour plots may be helpful

contourf(v,'upper')