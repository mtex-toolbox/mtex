function display(q)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('Rotations','Quaternion') ': (size: ' int2str(size(q.b)) ')']);

if numel(q) < 30 && numel(q)>0
  
  d = [q.a(:),q.b(:),q.c(:),q.d(:)];
  d(abs(d)<1e-13) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'a' 'b' 'c' 'd'});
end

disp(' ');
