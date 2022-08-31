function annotate(obj,varargin)
% annotate to a existing figure

% is only applicable for MTEX figures
if isempty(gcm), return; end

aS = getMTEXpref('annotationStyle');
plot(obj,aS{:},'add2all',varargin{:});
pause(0.01);
drawNow(gcm);

end
