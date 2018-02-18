function annotate(obj,varargin)
% annotate to a existing figure

aS = getMTEXpref('annotationStyle');
plot(obj,aS{:},'add2all',varargin{:});

end
