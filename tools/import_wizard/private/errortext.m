function s = errortext
e = lasterror;
e = e.message;
pos = strfind(e,'</a>');
s = e(pos+5:end);