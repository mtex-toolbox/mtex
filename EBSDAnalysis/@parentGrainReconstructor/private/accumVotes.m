function votes = accumVotes(grainId,parentId,fit,maxGrainId,varargin)
% turn parentId, grainId, fit votes into grain / parentId probabilities

numFit = get_option(varargin,'numFit',2);
fit = reshape(fit,[],numFit);
grainId = reshape(grainId,[],numFit);
parentId = reshape(parentId,[],numFit);

% restrict fit according to minFit and maxFit
% best fit needs to be smaller minFit 
minFit = get_option(varargin,'minFit',inf);
ind = fit(:,1) < minFit;

% second best fit needs to be lager maxFit
maxFit = get_option(varargin,'maxFit',-inf);
if size(fit,2)>1, ind = ind & fit(:,2) > maxFit; end

% restrict
fit = fit(ind,:);
grainId = grainId(ind,:);
parentId = parentId(ind,:);

% 
threshold = get_option(varargin,'threshold',min(2*degree,minFit));

% init table
votes = table('size',[maxGrainId,1],'VariableTypes',{'int32'},'VariableNames',{'parentId'});
numFit = get_option(varargin,'numFit',2);
numV = max(parentId(:));

if check_option(varargin,'bestFit')
  
  % find best fit for 
  fit = accumarray([grainId(:),parentId(:)],fit(:),[maxGrainId,numV],@min,nan);
  
  % sort result according to fit
  [votes.fit,votes.parentId] = sort(fit,2);
  
elseif check_option(varargin,'count')

  % count votes per grain
  count = accumarray([grainId(:), parentId(:)], fit(:) < threshold, [maxGrainId,numV],@sum, nan);

  % sort probabilities row-wise up to numFit
  [count,parentId] = sort(count,2,'descend');
  
  votes.parentId = parentId(:,1:numFit);
  votes.prob = count(:,1:numFit);
  
  
else % turn fits into probabilities
  
  % use the error function, which is the cumulative gaussian distribution
  tol = get_option(varargin,{'tol','tolerance'},threshold);
  prob = 1 - 0.5 * (1 + erf(2*(fit(:) - threshold)./tol));
  prob(prob < 1e-2) = 0;

  w = get_option(varargin,'weights',1);
  if size(w,1)>1 
    w = w(ind,:);
    prob = prob .* w(:);
  end
  
  % compute probability matrix
  % columns are different voteIds
  % rows are the different votings
  % value is the probability
  
  %probMax = accumarray([grainId(:), parentId(:)], prob, [maxGrainId,numV], @max);
  probMax = accumarray([grainId(:), parentId(:)], prob(:), [maxGrainId,numV],...
    @(x) quantile(x,1 - 1/(4*numFit)));
  
  prob = accumarray([grainId(:), parentId(:)], prob(:), [maxGrainId, numV]);
    
  prob = probMax .* prob ./ (sum(prob,2));

  % sort probabilities row-wise up to numFit
  [prob,parentId] = sort(prob,2,'descend');
  
  votes.parentId = parentId(:,1:numFit);
  votes.prob = prob(:,1:numFit);
    

end