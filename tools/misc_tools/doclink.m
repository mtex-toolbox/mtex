function linkText = doclink(fname,lname)

% on Octave skip this
if isOctave
  linkText = lname;
  return;
end


if exist('helpPopup','file')>0
  
  linkText = ['matlab:helpPopup(''' fname ''')'];
  
else
  
  linkText = ['matlab:web(''jar:file:///'  ...
    regexprep(fullfile(mtex_path,'','help','mtex','help.jar!',fname),'\','/') '.html'',''-helpbrowser'')'];
  
end


% check whether script is published
stack = dbstack;
if isempty(strmatch('publish',{stack.name},'exact'))
  
  % generate link text
  linkText = ['<a href="' linkText '">' lname '</a>'];
  
else
  linkText = lname;
end
