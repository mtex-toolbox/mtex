function display(o)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('orientation_index','orientation') ': (size: ' int2str(size(o)) ')']);
disp(['  symmetry: ',char(o.CS),' - ',char(o.SS)]);

if numel(o) < 30 && numel(o)>0
  
  disp('  Bunge Euler angles in degree: ');

  [phi1,Phi,phi2] = Euler(o,'Bunge');
  d = [phi1(:)/degree,Phi(:)/degree,phi2(:)/degree];
  d(abs(d)<1e-10)=0;
  cprintf(d,'-L','  ','-Lc',{'phi1' 'Phi' 'phi2' 'inversion'});

end

disp(' ');
