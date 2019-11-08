function linkText = doclink(fname,lname)

if nargin == 1
  if ischar(fname)
      lname = fname;
  else
    lname = class(fname);
  end
end
if ~ischar(fname), fname = [class(fname) '.' class(fname)]; end

if 0 && exist('helpPopup','file')>0
  
  linkText = ['matlab:helpPopup(''' fname ''')'];
  
else
  
  linkText = ['matlab:web(''file:///'  ...
    regexprep(fullfile(mtex_path,'','doc','html',fname),'\','/') '.html'',''-helpbrowser'')'];
  
end


% check whether script is published
stack = dbstack;
if isempty(strmatch('publish',{stack.name},'exact'))
  
  % generate link text
  linkText = ['<a href="' linkText '">' lname '</a>'];
  
else
  linkText = lname;
end
