function varargout = checkSinglePhase(ebsd)

% check only a single phase is involved
try
  
  if numel(unique(ebsd.phase)) > 1
    
    error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
      'Please see ' doclink('xx','xx')  ...
      '  for restrict EBSD data to a single phase.']);
    
  elseif numel(ebsd.phase) == 0
    
    error('MTEX:MultiplePhases',['The EBSD set is Empty! ' ...
      'Please see ' doclink('xx','xx') ' for restrict a EBSD data to a single phase.']);
    
  elseif any(isNotIndexed(ebsd))
    
     error('MTEX:MultiplePhases',['The EBSD data contains only non-indexed orientations! ' ...
      'Please see ' doclink('xx','xx') ' for restrict EBSD data to a single phase.']);
    
  end
  
  if nargout > 0
    varargout{1} = true;
  end
  
catch e
  throwAsCaller(e)
end