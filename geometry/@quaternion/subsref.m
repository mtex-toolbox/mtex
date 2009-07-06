function q = subsref(q,s)
% overloads subsref

% ss = s(1);
% switch ss.type
%   case '()'
%     q.a = subsref(q.a,ss);
%     q.b = subsref(q.b,ss);
%     q.c = subsref(q.c,ss);
%     q.d = subsref(q.d,ss);
%   case '.'
%     q = q.(ss.subs);
%   case '{}'
%     error('??? Cell contents reference from a non-cell array object.');
%   otherwise
%     error('wrong data type');
% end
% 
% if numel(s) > 1, q = subsref(q,s(2:end)); end

q.a = subsref(q.a,s);
q.b = subsref(q.b,s);
q.c = subsref(q.c,s);
q.d = subsref(q.d,s);
