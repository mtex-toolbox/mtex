function linkText = doclink(fname,lname)

% check whether script is published 
stack = dbstack;
if isempty(strmatch('publish',{stack.name},'exact'))

  % generate link text
  linkText = ['<a href="matlab:web(''jar:file:///'  ...
    fullfile(mtex_path,'','help','mtex','help.jar!',fname) ...
    '.html'',''-helpbrowser'')">' lname '</a>'];
else
  linkText = lname;
end