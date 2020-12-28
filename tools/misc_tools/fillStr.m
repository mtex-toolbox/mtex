function str = fillStr(str,len)

str = [str, repmat(' ',1,max(0,len-length(str)))];