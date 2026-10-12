function ds = dream3dDatasets(fname)
% the paths of all data sets of a DREAM.3D file
%
% Input
%  fname - file name
%
% Output
%  ds - column of strings
%
% Description
% Neither the names of the data containers nor those of their attribute
% matrices are fixed, so the importers locate their data by the name of
% the data set.

ds = walk(h5info(fname));

end

function ds = walk(group)

ds = strings(0,1);
if ~isempty(group.Datasets)
  ds = strip(group.Name,'right','/') + "/" + string({group.Datasets.Name}).';
end
for g = group.Groups.', ds = [ds; walk(g)]; end %#ok<AGROW>

end
