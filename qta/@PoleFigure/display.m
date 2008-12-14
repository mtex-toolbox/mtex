function display(pf)
% standard output

disp(' '); 
disp([inputname(1) ' = ']);
disp(' ');
if numel(pf)
  disp(['  PoleFigure, '  char(pf(1).CS) '/' char(pf(1).SS) ': ' pf(1).comment]);
else
  disp('  PoleFigure:');
end
for i = 1:numel(pf)
  if sum(size(pf(i).h))>0
    disp(['   ' ind2char(i,size(pf)) ' h: ' char(pf(i).h)  ', r: '  char(pf(i).r(1))  ]);
  end
end
disp(' ')