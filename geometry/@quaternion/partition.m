function cq = partition(q,pos)
% {[0 .. a] [a+1 ...b]}


cq = cell(numel(pos),1);

qf = q;
a = q.a;
b = q.b;
c = q.c;
d = q.d;

for k=1:numel(pos)
  ind = pos{k};
  
  qf.a = a(ind,:);
  qf.b = b(ind,:);
  qf.c = c(ind,:);
  qf.d = d(ind,:);
  
  cq{k} = qf;
end