function annotate(obj,varargin)
% annotate to a existing figure

aS = getMTEXpref('annotationStyle');
plot(obj,aS{:},'add2all',varargin{:});
pause(0.01);

if ~isempty(gcm), drawNow(gcm); end

end
