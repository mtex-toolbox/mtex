function [parentOri, fit] = calcParent(childOri,p2c,varargin)
%
% Syntax
%
%   % return parent orientation
%   [parentOri, fit] = calcParent(childOri,p2c)
%   [parentOri, fit] = calcParent(childOri,parentOri,p2c)
%   [parentOri, fit] = calcParent(childOri,parentOri,'numFit',2)
% 
%   % return parent id
%   [parentId, fit] = calcParent(childOri,p2c,'id')
%   [parentId, fit] = calcParent(childOri,parentRef,p2c,'id')
%
% Input
%  childOri    - child @orientation
%  parentOri   - parent @orientation
%  p2c         - parent to child mis@orientation
%  p2cVariants - variants of parent to child mis@orientation      
%
% Options
%  numFit    - do return up to n-th fit
%  id        - return parent variant id instead of parent ori
%
% Output
%  parentOri - parent @orientation
%  parentid  - parent variant Id 
%  fit       - fit to the given parent2child misorientation
%
% Description
%
%

% extract use case and reassign arguments
setting = size(childOri,2);
if setting <= 1
  if isa(p2c.SS,'crystalSymmetry')
    setting = 4;
  else
    parentOri = p2c;
    p2c = varargin{1};
    setting = 1;
  end
end
  
% number of fits
numFit = get_option(varargin,'numFit',1);

% maybe we have to swap p2c
if p2c.SS ~= childOri.CS, p2c = inv(p2c); end

% compute all parent variants
if length(p2c) == 1, p2c = variants(p2c,'parent'); end
p2c = reshape(p2c,[],1);
numV = length(p2c);

if setting == 1  % child + parent orientation
    
  % compute distance to all possible variants
  mori = inv(childOri) .* parentOri;
  fit = angle_outer(mori,p2c,'noSym2');

  if numFit == 1
  
    % take the best fit
    [fit,parentId] = min(fit,[],2);
    
  else
    
    [fit,parentId] = sort(fit,2);
  
    fit = fit(:,1:numFit);    
    parentId = parentId(:,1:numFit);
    
  end
  
  
elseif setting == 2     % child + child orientation, aka grain boundaries
  
  % compute all parent variants to child ori
  % this will result in a size(childOri) x number_of_variant table.
  pVariants = reshape(childOri * p2c,[size(childOri),numV]);

  fit = zeros(size(childOri,1),numV,numV);
  for i1=1:numV
    for i2 = 1:numV
      fit(:,i1,i2) = angle(pVariants(:,1,i1),pVariants(:,2,i2));
    end
  end
  progress(1,1);

  fit = reshape(fit,size(fit,1),numV^2);
  if numFit == 1
  
    % take the minimum
    [fit,parentId] = min(fit,[],2);

    % the ids of the best fitting variants can now be computed by
    [i1,i2] = ind2sub([numV numV],parentId);
    parentId = [i1,i2];
  
  else
  
    % sort fit
    [fit,parentId] = sort(fit,2);
  
    fit = fit(:,1:numFit);
    [i1,i2] = ind2sub([numV numV],reshape(parentId(:,1:numFit),size(fit,1),1,numFit));
    parentId = [i1,i2];
  
  end
  
  
elseif setting == 3 % child + child + child -> triple points

  % compute all parent variants to child ori
  % this will result in a size(childOri) x number_of_variant table.
  pVariants = reshape(childOri * p2c,[size(childOri),numV]);

  
  threshold = get_option(varargin,'threshold',10*degree);
  
  % Check whether the variants at the triple points are compatible, i.e.,
  % whether we find a betaOrientation which matches one of the variants of
  % all three adjacent grains. To this end we compute the disorientation
  % angle with respect to all combinations
 
  fit = -inf(size(childOri,1),numV,numV,numV);
  
  for i1=1:numV
    for i2 = 1:numV
      progress((i1-1)*numV + i2,numV^2 * 1.5);
      fit(:,i1,i2,:) = repmat(angle(pVariants(:,1,i1),pVariants(:,2,i2)),[1 1 1 numV]);
    end
  end
  
  for i2=1:numV
    for i3 = 1:numV
      ind = any(fit(:,:,i2,i3) < threshold,2);
      fit(ind,:,i2,i3) = max(fit(ind,:,i2,i3),...
        repmat(angle(pVariants(ind,2,i2),pVariants(ind,3,i3)),[1 numV 1 1]));
    end
    progress(numV^2 + 0.5* i2 * numV ,numV^2 * 1.5);
  end
  
  for i1=1:numV
    for i3 = 1:numV
      ind = any(fit(:,i1,:,i3) < threshold,3);
      fit(ind,i1,:,i3) = max(fit(ind,i1,:,i3),...
        repmat(angle(pVariants(ind,1,i1),pVariants(ind,3,i3)),[1 1 numV 1]));
    end
  end

  % Ideally, we would like to find i1, i2, i3 such that all the
  % disorientation angles mis12V(:,i1,i2,i3), mis13V(:,i1,i2,i3) and
  % mis23V(:,i1,i2,i3) all small. One way to do this is to find the minimum
  % of the sum
  %fit = reshape(sqrt(mis12V.^2 + mis13V.^2 + mis23V.^2),[],numV^3) / 3;
  %fit = reshape(max(max(mis12V,mis13V),mis23V),[],numV^3);
  fit = reshape(fit,[],numV^3);
  
  if numFit == 1
  
    % take the minimum
    [fit,parentId] = min(fit,[],2);

    % the ids of the best fitting variants can now be computed by
    [i1,i2,i3] = ind2sub([numV numV numV],parentId);
    parentId = [i1,i2,i3];
  
  else
  
    % sort fit
    [fit,parentId] = sort(fit,2);
  
    fit = fit(:,1:numFit);
    [i1,i2,i3] = ind2sub([numV numV numV],reshape(parentId(:,1:numFit),size(fit,1),1,numFit));
    parentId = [i1,i2,i3];
  
  end
elseif setting == 4 % arbitrarily many child orientations of one parent
  
  weights = get_option(varargin,'weights',ones(size(childOri)));
  weights = reshape(weights ./ sum(weights),[],1);
  
  [~,id] = max(weights);
  
  parentCanditates = childOri(id) * p2c;
  
  bestFit = inf;
  for k = 1:length(parentCanditates)
    
    pId = calcParent(childOri,parentCanditates(k),p2c,'id');
    pOri = childOri .* p2c(pId);
    
    parentCanditates(k) = mean(pOri,'weights',weights,'robust');
    
    fit(k) = angle(pOri, parentCanditates(k)).' * weights;
            
    if fit(k) < bestFit, parentId = pId; bestFit = fit(k); end
    
  end
  [~,id] = min(fit);
  fit = bestFit;
    
  if check_option(varargin,'id')
    parentOri = parentId;
  else
    
    parentOri = parentCanditates(id);
  end
  return
  
else
  error('wrong input')
end

% compute parent orientation corresponding to the best fit
if ~check_option(varargin,'Id')
  parentOri = childOri .* p2c.subSet(parentId);
else
  parentOri = parentId;
end

end