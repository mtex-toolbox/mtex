function disptmp(s,varargin)

global prevCharCnt;

if isempty(prevCharCnt) || ~isempty(lastwarn), prevCharCnt = 0; end
lastwarn('');
% Make safe for fprintf, replace control charachters

s = strrep(s,'%','%%');
s = strrep(s,'\','\\');

s = [s '\n'];
fprintf([repmat('\b',1, prevCharCnt) s]);
nof_extra = length(strfind(s,'%%'));
nof_extra = nof_extra + length(strfind(s,'\\'));
nof_extra = nof_extra + length(strfind(s,'\n'));
prevCharCnt = length(s) - nof_extra; %-1 is for \n

end