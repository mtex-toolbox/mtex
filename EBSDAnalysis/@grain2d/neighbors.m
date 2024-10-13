function pairs = neighbors(grains,varargin)
% returns the Ids of neighboring grains
%
% Syntax
%
%   % pairs of neighboring grains in grains1
%   pairs = neighbors(grains1)
%
%   % pairs of neighboring grains in grains1 and grains2
%   pairs = neighbors(grains1,grains2)
%
%   % all neighboring grains of grains1
%   pairs = neighbors(grains1,'full')
%
%   % adjacency matrix of grains
%   A = grains.neighbors('matrix')
%
% Input
%  grains1, grains2 - @grain2d
%
% Output
%  pairs  - index list of size N x 2
%  A - adjacency matrix
%
% Options
%  full   - consider all neighboring grains, not only those contained in 
%  matrix - provide the result as adjacency matrix
%

% extract grainIds for each boundary segment
gbid = grains.boundary.grainId;
gbid(any(gbid == 0,2),:) = [];

% sort columnwise
gbid = sort(gbid,2,'ascend');

% get unique pairs
pairs = unique(gbid,'rows');

% return adjacency matrix
if check_option(varargin,'matrix')
  
  maxId = get_option(varargin,'maxId',max(gbid(:)));
  
  % generate an adjacency matrix
  A = sparse(pairs(:,1),pairs(:,2),true,maxId,maxId);
  
  % symmetrise
  A = A | A.';
  
  % remove 
  ind = ismember(1:maxId,grains.id);
  A(~ind,:) = false;
  
  pairs = A;
  
elseif ~check_option(varargin,'full')
  % allow only neighbors within the same data set
  
  if nargin > 1 && isa(varargin{1},'grain2d')
    
    % TODO: this changes sorting even if it is not needed
    isIn2 = ismember(pairs,varargin{1}.id);
    isIn1 = ismember(pairs,grains.id);
    
    % second grain should always be in second column
    pairs(isIn2(:,1),:) = fliplr(pairs(isIn2(:,1),:));
    
    % ensure second grain is present everywhere
    pairs = pairs(all(isIn1 | isIn2,2) & any(isIn2,2),:);
    
  else
    pairs(any(~ismember(pairs,grains.id),2),:)=[];
  end
end
