function disptmp(s,varargin)

global prevCharCnt;

% \b doesn't work on logs, so turn diary off temporarily
if strcmp(get(0,'Diary'),'on')
    diary('off')
    turn_diary_on_when_done = onCleanup(@() diary('on'));
end

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