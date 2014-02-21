function ori = calcModes(component,~)
% return the modes of the component

ori = component.center(component.weights>=quantile(component.weights,-20));

end
