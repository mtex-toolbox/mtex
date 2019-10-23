%% Exporting Vectors
%
%%
% Large lists of vectors can be imported from a text file by the command

fname = fullfile(mtexDataPath,'vector3d','vectors.txt');
v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth angle'})

%%
% and exported by the command 

export(v,fname,'polar')
