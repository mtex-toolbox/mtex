function str = fillStr(str,len,varargin)

if check_option(varargin,'left')
  str = [repmat(' ',1,max(0,len-length(str))),str];
else
  str = [str, repmat(' ',1,max(0,len-length(str)))];
end