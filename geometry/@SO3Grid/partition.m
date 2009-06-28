function obj = partition(S3G, id)
% reorganize SO3Grid into sets of id
%
%% Syntax
%  g = partition(SO3Grid,id)
%
%% Input
%  SO3Grid  - @SO3Grid
%  id    - index set
%
%% Output
%  obj     - @SO3Grid
%

[id ndx] = sort(id);

sec = histc(id,unique(id))';
css = cumsum([0 sec]);

S3GT = S3G;
S3GT.Grid = quaternion; %due to memory
obj = repmat(S3GT,size(sec));

S3G.Grid = S3G.Grid(ndx);

for k = 1:length(sec)
   ids = css(k)+1:css(k+1);
   obj(k).Grid = S3G.Grid(ids);
end