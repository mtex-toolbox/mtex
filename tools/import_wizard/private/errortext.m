function s = errortext
e = lasterror;
s = e.message;
pos = strfind(s,'</a>');
if ~isempty(pos), s = s(pos+5:end);end