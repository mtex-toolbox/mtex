function varargout = checkSinglePhase(grains)

% check only a single phase is involved
try
  
  if numel(unique(grains.phase)) > 1
    
    error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
      'Please see ' doclink('xx','xx')  ...
      '  for restrict a GrainSet to a single phase.']);
    
  elseif numel(grains.phase) == 0
    
    error('MTEX:MultiplePhases',['The GrainSet is Empty! ' ...
      'Please see ' doclink('xx','xx') ' for restrict a GrainSet to a single phase.']);
    
  elseif any(isNotIndexed(grains))
    
     error('MTEX:MultiplePhases',['The GrainSet contains only non-indexed orientations! ' ...
      'Please see ' doclink('xx','xx') ' for restrict a GrainSet to a single phase.']);
    
  end
  
  if nargout > 0
    varargout{1} = true;
  end
  
catch e
  throwAsCaller(e)
end