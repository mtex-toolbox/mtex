function x = argin_check(arg,classes)
% check ar to be of class classes
%
% Syntax
%   x = argin_check(argument,classesnames)
%
% Input
%  argument   - variable
%  classnames - 
%
% Output
%  argument - 
%

if ~any(cellfun(@(className) isa(arg,className),ensurecell(classes)))
  
  % generate error string
  if iscellstr(classes)
    c = '';
    for i = 1:length(classes)-1
      c = [c,'"' classes{i},'", ']; %#ok<AGROW>
    end     
    c = [c, 'or "' classes{end},'"'];
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
