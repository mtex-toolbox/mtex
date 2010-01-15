function q = horzcat(varargin)
% implements [q1,q2,q3..]

% preallocation
qs = repmat(struct(varargin{1}),size(varargin));
% fill with structures from varargin
% supprisingly this is faster then cellfun
for k=1:numel(varargin)
  qs(k) = struct(varargin{k});
end

q = varargin{1};
q.a = horzcat(qs.a);
q.b = horzcat(qs.b);
q.c = horzcat(qs.c);
q.d = horzcat(qs.d);
