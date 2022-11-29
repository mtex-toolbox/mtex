function ori = calcModes(SO3F,~)
% return the modes of the component

ori = SO3F.center(SO3F.weights>=quantile(SO3F.weights,-20));

end
