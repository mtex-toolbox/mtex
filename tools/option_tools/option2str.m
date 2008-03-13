function s = option2str(options,varargin)
% transforms option list to comma separated list

if ~isempty(options)
  if check_option(varargin,'quoted')
    s = cellfun(@double2quotedstr,options,'uniformoutput',false);
  else
    s = cellfun(@double2str,options,'uniformoutput',false);
  end
  s = strcat(s,{', '});
  s = [s{:}];
  s = s(1:end-2);
else
  s = '';
end

function s = double2str(d)

if ischar(d)
  s = d;
elseif isa(d,'double')
  s = xnum2str(d);
  if length(d) > 1, s = ['[',s,']'];end
else
  s = char(d);
end

function s = double2quotedstr(d)

if ischar(d)
  s = ['''',d,''''];
elseif isa(d,'double')
  s = xnum2str(d);
  if length(d) > 1, s = ['[',s,']'];end
else
  s = ['''',char(d),''''];
end
