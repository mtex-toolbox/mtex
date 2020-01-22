function [vGrid,wGrid,id] = gridify(v,varargin)
% 
%
%

res = get_option(varargin,'resolution',2.5*degree);

if v.antipodal, aP = {'antipodal'}; else, aP = {}; end
if isa(v,'Miller')
  sR = v.CS.fundamentalSector;
  v = project2FundamentalRegion(v);
else
  sR = sphericalRegion(aP{:});
end

vGrid = equispacedS2Grid('resolution',res,sR,aP{:});

wGrid = get_option(varargin,'weights',ones(length(v),1));

% construct a sparse matrix showing the relation between both grids
id = find(vGrid,v);
M = sparse(1:length(v),id,wGrid,length(v),length(vGrid));

% compute weights
wGrid = full(sum(M,1)).';
  
% eliminate spare vectors in the grid
vGrid = subGrid(vGrid,wGrid~=0);
wGrid = wGrid(wGrid~=0);

if isa(v,'Miller'), vGrid = Miller(vGrid,v.CS); end