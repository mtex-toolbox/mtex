function display(o)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('CrystalOrientations','orientation') ': (size: ' int2str(size(o)) ')']);
disp(['  symmetry: ',char(o.CS),' - ',char(o.SS)]);

if numel(o.i) < 30 && numel(o)>0
  
  disp('  Bunge Euler angles in degree: ');
  %q = getFundamentalRegion(o);
  [phi1,Phi,phi2] = Euler(o,'Bunge');
  if any(o.i(:) < 0)
    d = [phi1(:)/degree,Phi(:)/degree,phi2(:)/degree,o.i(:)];
  else
    d = [phi1(:)/degree,Phi(:)/degree,phi2(:)/degree];
  end
  d(abs(d)<1e-10)=0;
  cprintf(d,'-L','  ','-Lc',{'phi1' 'Phi' 'phi2' 'inversion'});

end

disp(' ');
