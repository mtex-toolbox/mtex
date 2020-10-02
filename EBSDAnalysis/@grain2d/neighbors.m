function pairs = neighbors(grains,varargin)
% returns the Ids of neighboring grains
%
% Syntax
%
%   % neighbouring relationships within grains
%   pairs = neighbors(grains)
%   pairs = neighbors(grains1,grains2)
%
%   % all neighbouring relationships
%   pairs = neighbors(grains,'full')
%
% Input
%  grains - @grain2d
%
% Output
%  pairs  - index list of size N x 2
%


% extract grainIds for each boundary segment
gbid = grains.boundary.grainId;
gbid(any(gbid == 0,2),:) = [];

% sort columnwise
gbid = sort(gbid,2);

% get unique pairs
pairs = unique(gbid,'rows');

% allow only neighbours within the same data set
if ~check_option(varargin,'full')
  if nargin > 1 && isa(varargin{1},'grain2d')
    
    isIn2 = ismember(pairs,varargin{1}.id);
    
    % second grain should aways be in second column
    pairs(isIn2(:,1),:) = fliplr(pairs(isIn2(:,1),:));
    
    % ensure second grain is present everywhere
    pairs(~any(isIn2,2),:)=[];
    
  else
    pairs(any(~ismember(pairs,grains.id),2),:)=[];
  end
end
