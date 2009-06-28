function varargout = subsref(q,s)
% overloads subsref

% if isa(s,'double')
%   q.a = q.a(s);
%   q.b = q.b(s);
%   q.c = q.c(s);
%   q.d = q.d(s);  
% 	varargout{1} = q;
% else
  ss = s(1);
  switch ss.type
    case '()'
      q.a = subsref(q.a,ss);
      q.b = subsref(q.b,ss);
      q.c = subsref(q.c,ss);
      q.d = subsref(q.d,ss);
    case '{}'
      varargout = cell(1,nargout);
    case '.'
      q = q.(ss.subs);
    otherwise
      error('wrong data type');
  end
  if numel(s) == 1
    varargout{1} = q;   
  else
    varargout{1} = subsref(q,s(2:end));         
  end
% end

