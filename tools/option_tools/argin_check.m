function x = argin_check(arg,classes)
% check ar to be of class classes
%
%% Input
%  argument
%  classnames
%% Output
%  argument

if isempty(strmatch(class(arg),classes))
  if iscellstr(classes)
    c = ['"',[classes{1:end-1},'", "'],classes{end},'"'];
  else
    c = ['"' classes '"'];
  end
  
  caller = dbstack;caller = caller(2).name;
  help(caller);
  error('Input argument "%s" should be of type %s\nSee syntax definition above!',...
    inputname(1),c);
  
%  try 
%    error('Input argument "%s" should be of type %s\nSee syntax definition above!',...
%      inputname(1),c);
%  catch ME
%    throwAsCaller(ME);
%  end
end

x = arg;
