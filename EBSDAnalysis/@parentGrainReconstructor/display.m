function display(job,varargin)
      
vname = get_option(varargin,'name',inputname(1));
varargin = delete_option(varargin,'name',1);
displayClass(job,vname,varargin{:});

disp(' ');

gs = job.grains.grainSize;
p = 100*sum(gs(job.grains.phaseId == job.parentPhaseId)) / sum(gs);
matrix(1,:) = {'parent', job.csParent.mineral, char(job.csParent), ...
  length(job.grains(job.csParent)),[xnum2str(p) '%']};

p = 100*sum(gs(job.grains.phaseId == job.childPhaseId)) / sum(gs);
if ~isempty(job.csChild)
  matrix(2,:) = {'child', job.csChild.mineral, char(job.csChild), ...
    length(job.grains(job.csChild)),[xnum2str(p) '%']};
end

cprintf(matrix,'-L',' ','-Lc',...
  {'phase' 'mineral' 'symmetry' 'grains' 'area'},...
  '-d','  ','-ic',true,'-la','T');

if ~isempty(job.p2c)
  disp(' ');
  disp([' parent to child OR: ' round2Miller(job.p2c)])
end

% display graph information
if ~isempty(job.graph) && size(job.graph,2) == length(job.grains)
 
  disp(' ');
  [~,mId] = merge(job.grains, job.graph,'testRun');
  numComp = accumarray(mId,1);
  untouched = nnz(numComp==1);
  numComp = numComp(numComp>1);
  
  disp([' mergable grains: ' int2str(sum(numComp)) ...
    ' -> ' int2str(length(numComp)) ' keep ' int2str(untouched)]);
 
end

% display vote information
if ~isempty(job.votes)
  disp(' ');
  omega = job.votes.fit(:,1);
  omega = mean(omega(omega < quantile(omega,0.5)))./degree;
  disp([' mean fit: ' xnum2str(omega) getMTEXpref('degreeChar')]);
end

%I would prefer an expression based on "isTransformed". I am not sure if 20
%percent preexisting austenite should be indexed as "20% transformed" if no
%reconstruction has been started. What do you think?
%recAreaGrains = sum(job.grains(job.csParent).area)/sum(job.grains.area)*100;
%recAreaEBSD = length(job.ebsd(job.csParent))/length(job.ebsd)*100;
%fprintf('  grains reconstructed: %.0f%%\n', recAreaGrains);
%fprintf('  ebsd reconstructed: %.0f%%\n', recAreaEBSD);

end