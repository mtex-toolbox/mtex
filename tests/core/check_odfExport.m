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
