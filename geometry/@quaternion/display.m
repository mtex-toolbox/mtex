function display(q)
% standart output

displayClass(q,inputname(1));

if length(q)~=1, disp(['  size: ' size2str(q)]); end

if length(q) < 30 && ~isempty(q)
  
  d = [q.a(:),q.b(:),q.c(:),q.d(:)];
  d(abs(d)<1e-13) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'a' 'b' 'c' 'd'});
end
