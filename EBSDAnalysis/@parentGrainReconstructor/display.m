function display(job,varargin)
      
displayClass(job,inputname(1),varargin{:});

disp(' ');

gs = job.grains.grainSize;
p = 100*sum(gs(job.grains.phaseId == job.parentPhaseId)) / sum(gs);
matrix(1,:) = {'parent', job.csParent.mineral, job.csParent.pointGroup, ...
  nnz(job.isParent),[xnum2str(p) '%'],...
  [xnum2str(100*nnz(job.isTransformed)./nnz(job.grainsPrior.phaseId ==job.childPhaseId)) '%']};

p = 100*sum(gs(job.grains.phaseId == job.childPhaseId)) / sum(gs);
if ~isempty(job.csChild)
  matrix(2,:) = {'child', job.csChild.mineral, job.csChild.pointGroup, ...
    nnz(job.isChild),[xnum2str(p) '%'],''};
end

cprintf(matrix,'-L',' ','-Lc',...
  {'phase' 'mineral' 'symmetry' 'grains' 'area' 'reconstructed'},...
  '-d','  ','-ic',true,'-la','T');

if ~isempty(job.p2c)
  disp(' ');
  disp([' OR: ' char(job.p2c)]);
  prop = calcGBFit(job,'p2c','quick')./degree;
  if ~isempty(prop)
    disp(['   p2c fit: '...
      xnum2str(quantile(prop,0.2)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prop,0.4)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prop,0.6)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prop,0.8)) getMTEXpref('degreeChar') ...
      ' (quintiles)']);
  end
  
  prop = calcGBFit(job,'c2c','quick')./degree;
  if ~isempty(prop)
    disp(['   c2c fit: '...
      xnum2str(quantile(prop,0.2)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prop,0.4)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prop,0.6)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prop,0.8)) getMTEXpref('degreeChar') ...
      ' (quintiles)']);
  end
  
  OR = round2Miller(job.p2c,'maxHKL',5);
  if angle(OR,job.p2c) > 1e-3*degree
    disp(['   closest ideal OR: ' char(OR) ' fit: ' ...
      xnum2str(angle(OR,job.p2c)./degree) '°'])
  end
  % Here we still obtain that the (110) of austenite is parallel to (111) in martensite, 
  % which is the reverse in reality. We have had this discussion before, and I think that  
  % we should keep things as they are, as they are crystallographically not
  % wrong. The conventionally reported OR just takes the planes that are
  % found at the crystal interface which is (111) in austenite and (110) in
  % martensite.
end

% display graph information
if ~isempty(job.graph) && size(job.graph,2) == length(job.grains)
 
  disp(' ');
  [~,mId] = merge(job.grains, job.graph,'testRun');
  numComp = accumarray(mId,1);
  untouched = nnz(numComp==1);
  numComp = numComp(numComp>1);
  
  disp([' graph: ' int2str(sum(numComp)) ...
    ' grains in ' int2str(length(numComp)) ' clusters + ' int2str(untouched) ' single grain clusters']);

elseif job.hasVariantGraph

  disp(' ');
  disp([' variant graph: ' int2str(nnz(job.graph)) ...
    ' entries']);

end

% display vote information
if ~isempty(job.votes)
  
  switch job.votes.Properties.VariableNames{2}
    case 'fit'
    
      prop = job.votes.fit ./ degree;
      name = 'fit';
      symb = '°';
      
    case 'prob'
      
      prop = 100 * job.votes.prob;
      name = 'probabilities';
      symb = '%';
    
    case 'count'
     
      prop = 100 * job.votes.counts;
      name = 'counts';
      symb = '';
      
  end
      
  prop = prop(~isnan(prop(:,1)),1);
  
  if ~isempty(prop)

    disp(' ');

    disp([' votes: ' size2str(prop)]);
    disp(['   ' name ': ' xnum2str(quantile(prop,0.8)) symb ...
      ', ' xnum2str(quantile(prop,0.6)) symb ...
      ', ' xnum2str(quantile(prop,0.4)) symb ...
      ', ' xnum2str(quantile(prop,0.2)) symb ...
      ' (quintiles)']);
    
  end
end

disp(' ')

end