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
obj = repmat(S3G,size(sec));

for k = 1:length(sec)
   ids = css(k)+1:css(k+1);
   obj(k).Grid = S3G.Grid(ndx(ids));
end