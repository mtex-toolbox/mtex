function check_mtex

tic

disp('checking MTEX installation');
disp('this might take some time');
disp(' ');

disp('simulating pole figures')
[CS,SS] = get(SantaFe,'symmetry'); %#ok<NASGU>

% crystal directions
h = [Miller(1,0,0,CS),Miller(1,1,0,CS),Miller(1,1,1,CS),Miller(2,1,1,CS)];

% specimen directions
r = S2Grid('equispaced','resolution',10*degree,'antipodal');

% pole figures
pf = calcPoleFigure(SantaFe,h,r) %#ok<NOPRT>

disp(' ');

% recalculate odf
rec = calcODF(pf) %#ok<NOPRT>

disp(' ');
disp('check reconstruction error: ')

% calculate error
if mean(calcError(pf,rec,'RP',1)) < 0.1
  disp('')
  disp('everythink seems to be ok!');
  disp('');
  toc
else
  error('somethink went wrong!')
end
