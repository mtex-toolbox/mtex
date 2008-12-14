function g = grains(obj,ids)
% convert grainid to EBSD objects
%
%% Input
%  ebsd - @EBSD
%  ids  - index set
%
%% Output
%  g    - ebsd as grains
%

if isempty(obj.grainid), 
  warning('matlab:EBSD:noGrains',...
    ['grain segmentation not done, try \n '...
    inputname(1) ' = segment(' inputname(1) ')']);
  return; 
end

grainid = cell2mat(obj.grainid);

if nargin > 1
  if islogical(ids), ids = find(ids);end 
else
  ids = 1:size(unique(grainid),1);
end


nw = length(ids);


cs = [0, cumsum(length(obj))];

n = numel(obj);

g = EBSD();
g.orientations = SO3Grid;
g.xy = {[]};
g.grainid = {[]};
g.comment = obj.comment;
vname = fields(obj.options);
for k=1:length(vname)
  g.options(1).(vname{k}) = {};
end
%tic
for i=1:nw
  id = find(grainid == ids(i));  
  gr = n - sum(id(1) <= cs) + 1;
  b = subsref(obj,substruct('()',{gr,id-cs(gr)}));

  g.orientations(i) = b.orientations;
  g.xy(i,1) = b.xy;
  g.phase{i,1} = b.phase{:};
  g.grainid(i,1) = b.grainid;
 
  for k=1:length(vname)
    g.options(1).(vname{k})(i,1) = b.options(1).(vname{k});
  end
end
%toc