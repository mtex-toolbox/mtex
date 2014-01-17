function ori = calcModes(component,~)
% return the modes of the component

ori = orientation(component.CS,component.SS);

end
