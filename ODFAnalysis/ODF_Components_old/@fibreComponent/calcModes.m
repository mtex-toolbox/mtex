function ori = calcModes(component,res)
% return the modes of the component

ori = orientation(fibre(component.h, component.r, ...
  component.CS, component.SS), 'resolution',res);

end
