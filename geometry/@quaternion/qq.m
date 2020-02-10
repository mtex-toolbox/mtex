function T = qq(q,varargin)
% returns w * q' * q
% 
% Input
%  q - list of quaternions
%  w - list of weights

notNaN = ~isnan(q.a);
ql = [q.a(:), q.b(:), q.c(:), q.d(:)];
ql = ql(notNaN,:);

% weigths
w = get_option(varargin,'weights');

if ~isempty(w)
  w = w(notNaN);
  w = w./sum(w);
  w = repmat(w(:).',4,1);
  T = (w .* ql.') * ql;
else
  T = ql.'*ql;
  T = T ./ size(ql,1);
end




