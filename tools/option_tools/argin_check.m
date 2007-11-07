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
  error('Input argument "%s" should be of type %s',inputname(1),c);
end

x = arg;
