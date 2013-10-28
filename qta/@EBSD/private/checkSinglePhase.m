function [ebsd,cs] = checkSinglePhase(ebsd)

% check only a single phase is involved
try
  
  % restrict to indexed phases
  phases = find(cellfun(@(cs) isa(cs,'symmetry'),ebsd.CS));
  
  phases = intersect(phases,unique(ebsd.phaseId));
  
  if numel(phases) > 1
  
    error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
      'Please see ' doclink('EBSDModifyData','modify EBSD data')  ...
      ' for how to restrict EBSD data to a single phase.']);
  
  elseif isempty(phases)
    
    error('MTEX:NoPhase','There are no indexed data in this variable!');
    
  end
  
  ebsd = subSet(ebsd,ebsd.phaseId == phases);
  cs = ebsd.CS{phases};
  
  if numel(ebsd.phaseId) == 0
    error('MTEX:MultiplePhases','The EBSD set is Empty!');
  end
    
catch e
  throwAsCaller(e)
end