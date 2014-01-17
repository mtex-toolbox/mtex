function s = option2str(options,varargin)
% transforms option list to comma separated list

if isstruct(options)
  
  s = 'TODO';
  
else
  
  if ~isempty(options)
    if check_option(varargin,'quoted')
      s = cellfun(@double2quotedstr,options,'uniformoutput',false);
      s{1} = [', ' s{1}];
    else
      s = cellfun(@double2str,options,'uniformoutput',false);
    end
    s = strcat(s,{', '}); % add this to every line
    s = [s{:}];           % now make one line out of all lines
    s = s(1:end-2);       % remove the leading and the ending coma
  else
    s = '';
  end
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
  if strfind(d,'*degree')
    s = d;
  else
    s = ['''',d,''''];
  end
elseif isa(d,'cell')  
   s = strcat(' ''',d,'''');
   s = ['{',s{:},'}'];
elseif isa(d,'double')
  s = xnum2str(d);
  if length(d) > 1, s = ['[',s,']'];end
else
  s = ['''',char(d),''''];
end
