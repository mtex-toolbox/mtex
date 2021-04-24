function display(job,varargin)
      
vname = get_option(varargin,'name',inputname(1));
varargin = delete_option(varargin,'name',1);
displayClass(job,vname,varargin{:});

disp(' ');

gs = job.grains.grainSize;
p = 100*sum(gs(job.grains.phaseId == job.parentPhaseId)) / sum(gs);
matrix(1,:) = {'parent', job.csParent.mineral, job.csParent.pointGroup, ...
  length(job.grains(job.csParent)),[xnum2str(p) '%'],...
  [xnum2str(100*nnz(job.isTransformed)./nnz(job.grainsPrior.phaseId ==job.childPhaseId)) '%']};

p = 100*sum(gs(job.grains.phaseId == job.childPhaseId)) / sum(gs);
if ~isempty(job.csChild)
  matrix(2,:) = {'child', job.csChild.mineral, job.csChild.pointGroup, ...
    length(job.grains(job.csChild)),[xnum2str(p) '%'],''};
end

cprintf(matrix,'-L',' ','-Lc',...
  {'phase' 'mineral' 'symmetry' 'grains' 'area' 'reconstructed'},...
  '-d','  ','-ic',true,'-la','T');

if ~isempty(job.p2c)
  disp(' ');
  disp([' OR: ' char(job.p2c)]);
  prob = calcGBFit(job,'p2c')./degree;
  if ~isempty(prob)
    disp(['   p2c fit: '...
      xnum2str(quantile(prob,0.2)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prob,0.4)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prob,0.6)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prob,0.8)) getMTEXpref('degreeChar') ...
      ' (quintiles)']);
  end
  
  prob = calcGBFit(job,'c2c')./degree;
  if ~isempty(prob)
    disp(['   c2c fit: '...
      xnum2str(quantile(prob,0.2)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prob,0.4)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prob,0.6)) getMTEXpref('degreeChar') ...
      ', ' xnum2str(quantile(prob,0.8)) getMTEXpref('degreeChar') ...
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
 
end

% display vote information
if ~isempty(job.votes)
  disp(' ');
  prob = 100*job.votes.prob(job.isChild,:);
  
  disp([' votes: ' size2str(prob)]);
  prob = prob(:,1);
  disp(['   probabilities: ' xnum2str(quantile(prob,0.8)) '%' ...
    ', ' xnum2str(quantile(prob,0.6)) '%' ...
    ', ' xnum2str(quantile(prob,0.4)) '%' ...
    ', ' xnum2str(quantile(prob,0.2)) '%' ...
    ' (quintiles)']);  
end

disp(' ')

end