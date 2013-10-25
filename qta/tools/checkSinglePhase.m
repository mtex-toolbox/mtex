function [obj,cs] = checkSinglePhase(obj)

% remove not indexed phase
obj(isNotIndexed(obj)) = [];

% check only a single phase is involved
try
  
  phase = unique(obj.phase);
  if numel(phase) > 1    
    error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
      'Please see ' doclink('ebsdModifyData','modify EBSD data')  ...
      '  for how to restrict EBSD data to a single phase.']);     
  end
  
  cs = obj.CS{phase};
      
catch e
  throwAsCaller(e)
end
