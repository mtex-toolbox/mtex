function check_odfExport
% check that SO3Fun/export picks the interface the caller asked for
%
% export(odf,file,'VPSC') silently wrote a generic file: the interface was
% only ever read with get_option(varargin,'interface','generic'), so a bare
% flag - which is how every other MTEX command takes such a choice, and how
% the doc pages wrote it - was ignored. An unknown interface used to reach
% feval as export_<whatever> and fail with an undefined function message.

odf = SO3FunRBF(orientation.rand(3,crystalSymmetry('m-3m')), ...
  SO3DeLaValleePoussinKernel('halfwidth',20*degree));

checkFlagMatchesOption(odf,'VPSC');
checkFlagMatchesOption(odf,'mtex');
checkInterfacesDiffer(odf);
checkDefault(odf);
checkUnknown(odf);
checkVPSCRoundTrip;
checkVPSCConvention;
checkVPSCDetection;

disp('check_odfExport: passed');

end

% =========================================================================
function checkFlagMatchesOption(odf,name)
% the bare flag has to do exactly what the interface option does

byFlag   = writeAndRead(odf,{name});
byOption = writeAndRead(odf,{'interface',name});

assert(isequal(byFlag,byOption), ...
  'check_odfExport: export(odf,file,''%s'') differs from ''interface'',''%s''',...
  name, name)

end

% -------------------------------------------------------------------------
function checkInterfacesDiffer(odf)
% guard against all three silently writing the same thing, which is the
% failure this test exists for

generic = writeAndRead(odf,{});
mtex    = writeAndRead(odf,{'mtex'});
vpsc    = writeAndRead(odf,{'VPSC'});

assert(~isequal(generic,mtex) && ~isequal(generic,vpsc) && ~isequal(mtex,vpsc), ...
  'check_odfExport: the three interfaces do not produce three different files')

end

% -------------------------------------------------------------------------
function checkDefault(odf)
% no interface given is still generic

assert(isequal(writeAndRead(odf,{}),writeAndRead(odf,{'interface','generic'})), ...
  'check_odfExport: the default is no longer the generic interface')

end

% -------------------------------------------------------------------------
function checkUnknown(odf)
% an unknown interface has to say so

try
  export(odf,[tempname '.txt'],'interface','nonsense');
  error('check_odfExport:noError', ...
    'check_odfExport: an unknown interface was accepted')
catch ME
  assert(strcmp(ME.identifier,'MTEX:export:unknownInterface'), ...
    'check_odfExport: an unknown interface raised %s instead of MTEX:export:unknownInterface',...
    ME.identifier)
end

end

% -------------------------------------------------------------------------
function checkVPSCRoundTrip
% what export_VPSC writes, loadODF_VPSC has to read back
%
% It could not: the loader identified a VPSC file by the string 'TEXTURE AT
% STRAIN' on the first line, which only VPSC *output* carries - neither an
% MTEX export nor a hand written weight file has it - so the round trip
% failed outright for eight years, issue #297.

cs = crystalSymmetry('mmm');
ori = orientation.byEuler(rand(50,3).*[2*pi pi/2 pi/2],cs);

fname = [tempname '.txt'];
cleanup = onCleanup(@() delete(fname)); %#ok<NASGU>
export_VPSC(ori,fname);

odf = loadODF_VPSC(fname,'cs',cs);

assert(length(odf.opt.orientations) == length(ori), ...
  'check_odfExport: the VPSC round trip returned %d of %d orientations',...
  length(odf.opt.orientations),length(ori))

% the file stores Euler angles to 0.01 degree
assert(max(angle(ori,odf.opt.orientations)) < 0.05*degree, ...
  'check_odfExport: the VPSC round trip changed the orientations by %.3f degree',...
  max(angle(ori,odf.opt.orientations))/degree)

end

% -------------------------------------------------------------------------
function checkVPSCConvention
% the fourth header line names the convention the columns are written in
%
% It used to be hardcoded to 'B' while the angles followed whatever
% EulerAngleConvention resolved to, so a Kocks export was silently labelled
% Bunge and read back as a different texture.

cs = crystalSymmetry('mmm');
ori = orientation.byEuler(rand(50,3).*[2*pi pi/2 pi/2],cs);

for convention = {'Bunge','Kocks','Roe'}

  fname = [tempname '.txt'];
  cleanup = onCleanup(@() delete(fname)); %#ok<NASGU>
  export_VPSC(ori,fname,convention{1});

  head = file2cell(fname,4);
  assert(strncmpi(head{4},convention{1},1), ...
    'check_odfExport: a %s export is labelled "%s"',convention{1},head{4})

  odf = loadODF_VPSC(fname,'cs',cs);
  assert(max(angle(ori,odf.opt.orientations)) < 0.05*degree, ...
    'check_odfExport: the %s round trip changed the orientations by %.3f degree',...
    convention{1},max(angle(ori,odf.opt.orientations))/degree)

end

end

% -------------------------------------------------------------------------
function checkVPSCDetection
% a weight file without the strain marker is VPSC, an ODF file is not

fname = [tempname '.txt'];
cleanup = onCleanup(@() delete(fname)); %#ok<NASGU>

fid = fopen(fname,'w');
fprintf(fid,'a comment\nanother one\n\nB 3\n');
fprintf(fid,'%7.2f %7.2f %7.2f %11.7f\n',[10 20 30 1/3; 40 50 60 1/3; 70 80 10 1/3].');
fclose(fid);

odf = loadODF_VPSC(fname,'cs',crystalSymmetry('mmm'));
assert(length(odf.opt.orientations) == 3, ...
  'check_odfExport: a VPSC weight file without the strain marker was not read')

% and the interface must not claim files that are not VPSC at all
fid = fopen(fname,'w');
fprintf(fid,'%% MTEX ODF\n%% phi1 Phi phi2 value\n0 0 0 1\n10 10 10 2\n');
fclose(fid);

try
  loadODF_VPSC(fname,'cs',crystalSymmetry('mmm'));
  error('check_odfExport:noError', ...
    'check_odfExport: the VPSC interface accepted a generic ODF file')
catch ME
  assert(~strcmp(ME.identifier,'check_odfExport:noError'),ME.message)
end

end

% =========================================================================
function txt = writeAndRead(odf,opts)

fname = [tempname '.txt'];
cleanup = onCleanup(@() delete(fname));

% the VPSC interface writes a discrete sample of the ODF, so two exports of
% the same object are only comparable from the same random state
rng(0)
export(odf,fname,opts{:});

fid = fopen(fname);
txt = fread(fid,'*char').';
fclose(fid);

end
