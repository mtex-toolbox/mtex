function annotate(obj,varargin)
% annotate to a existing figure

washold = getHoldState;
hold on
aS = getMTEXpref('annotationStyle');
plot(obj,aS{:},'add2all',varargin{:});
hold(washold);

end
