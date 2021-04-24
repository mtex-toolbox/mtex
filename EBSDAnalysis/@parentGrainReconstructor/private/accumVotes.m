function votes = accumVotes(grainId,parentId,fit,maxGrainId,varargin)
% turn parentId, grainId, fit votes into grain / parentId probabilities

numFit = get_option(varargin,'numFit',2);
fit = reshape(fit,[],numFit);
grainId = reshape(grainId,[],numFit);
parentId = reshape(parentId,[],numFit);

% ensure best fit is smaller minFit and second best fit is lager maxFit
minFit = get_option(varargin,'minFit',inf);
maxFit = get_option(varargin,'maxFit',-inf);

ind = fit(:,1) < minFit & fit(:,2) > maxFit;
fit = fit(ind,:);
grainId = grainId(ind,:);
parentId = parentId(ind,:);

% turn fits into probabilities
threshold = get_option(varargin,'threshold',min(2*degree,minFit));
tol = get_option(varargin,{'tol','tolerance'},threshold);

if check_option(varargin,'count') % no tolerance -> cut-off function 
  
  prob = fit(:) < threshold;
  
else
  % otherwise we use the error function, which is the cumulative gaussian
  % distribution
  
  prob = 1 - 0.5 * (1 + erf(2*(fit(:) - threshold)./tol));
  prob(prob < 1e-2) = 0;
  
end

%if any(strcmp(job.votes.Properties.VariableNames,'weights'))
%  prob = prob .* sqrt(job.votes.weights);
%end
  
% init table
numFit = get_option(varargin,'numFit',2);
votes = table(zeros(maxGrainId,numFit),zeros(maxGrainId,numFit),'VariableNames',{'parentId','prob'});

if check_option(varargin,'count')
  
  % simply add up the probabilities
  W = accumarray([grainId(:), parentId(:)], prob, [maxGrainId,max(parentId(:))]);
  
else % compute probability by parentId
  % probability matrix
  % columns are different voteIds
  % rows are the different votings
  % value is the probability
  W = full(sparse(grainId(:), parentId(:), prob, maxGrainId, max(parentId(:))));
  
  %Wmax = accumarray([grainId(:), parentId(:)], prob, [maxGrainId,max(parentId(:))], @max);
  Wmax = accumarray([grainId(:), parentId(:)], prob, [maxGrainId,max(parentId(:))],...
    @(x) quantile(x,1 - 1/(4*numFit)));
  
  W = Wmax .* W ./ (sum(W,2));
end

% sort probabilities row-wise up to numFit
for k = 1:numFit
  [votes.prob(:,k), votes.parentId(:,k)] = max(W,[],2);
  
  W(sub2ind(size(W), 1:maxGrainId, votes.parentId(:,k).')) = nan;
end

end