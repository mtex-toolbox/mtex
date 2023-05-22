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
gbid = sort(gbid,2,'ascend');

% get unique pairs
pairs = unique(gbid,'rows');

% return adjecency matrix
if check_option(varargin,'matrix')
  
  maxId = get_option(varargin,'maxId',max(gbid(:)));
  
  % generate an adjecency matrix
  A = sparse(pairs(:,1),pairs(:,2),true,maxId,maxId);
  
  % symmetrise
  A = A | A.';
  
  % remove 
  ind = ismember(1:maxId,grains.id);
  A(~ind,:) = false;
  
  pairs = A;
  
elseif ~check_option(varargin,'full')
  % allow only neighbours within the same data set
  
  if nargin > 1 && isa(varargin{1},'grain2d')
    
    % TODO: this changes sorting even if it is not needed
    isIn2 = ismember(pairs,varargin{1}.id);
    isIn1 = ismember(pairs,grains.id);
    
    % second grain should aways be in second column
    pairs(isIn2(:,1),:) = fliplr(pairs(isIn2(:,1),:));
    
    % ensure second grain is present everywhere
    pairs = pairs(all(isIn1 | isIn2,2) & any(isIn2,2),:);
    
  else
    pairs(any(~ismember(pairs,grains.id),2),:)=[];
  end
end
