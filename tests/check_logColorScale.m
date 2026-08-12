function check_logColorScale
% check that the 'logarithmic' flag reaches the color scale
%
% The flag documented on plotPDF, plotIPDF and plotSection was ignored:
% @vector3d/smooth, which is where a contoured spherical plot sets the
% color scale, only ever tested for the short spelling 'log'. So
% plotPDF(odf,h,'contourf','logarithmic') produced a plot indistinguishable
% from one without the flag - same ColorScale, same color limits.
%
% Both spellings are accepted everywhere else that takes this choice, see
% optionplot and setColorRange, which is why the long one was written in the
% first place.

odf = SO3FunRBF(orientation.rand(5,crystalSymmetry('m-3m')), ...
  SO3DeLaValleePoussinKernel('halfwidth',15*degree));

old = get(0,'DefaultFigureVisible');
cleanup = onCleanup(@() set(0,'DefaultFigureVisible',old));
set(0,'DefaultFigureVisible','off');

checkFlag(odf,'logarithmic','log');
checkFlag(odf,'log','log');
checkFlag(odf,'','linear');

checkSetColorRange;

disp('check_logColorScale: passed');

end

% =========================================================================
function checkFlag(odf,flag,expected)

h = Miller(1,0,0,odf.CS);

for cmd = {'plotPDF','plotIPDF'}

  figure
  cleanup = onCleanup(@() close('all','force')); %#ok<NASGU>

  if strcmp(cmd{1},'plotPDF')
    args = {odf,h,'contourf'};
  else
    args = {odf,vector3d.Z,'contourf'};
  end
  if ~isempty(flag), args = [args,{flag}]; end %#ok<AGROW>

  feval(cmd{1},args{:});

  scale = get(gca,'ColorScale');
  assert(strcmp(scale,expected), ...
    'check_logColorScale: %s with ''%s'' gives ColorScale %s, expected %s', ...
    cmd{1}, flag, scale, expected)

end

end

% -------------------------------------------------------------------------
function checkSetColorRange
% setColorRange documents 'log' and now takes the long spelling as well

odf = SO3FunRBF(orientation.rand(3,crystalSymmetry('m-3m')), ...
  SO3DeLaValleePoussinKernel('halfwidth',20*degree));

for flag = {'log','logarithmic'}

  figure
  cleanup = onCleanup(@() close('all','force')); %#ok<NASGU>

  plotPDF(odf,Miller(1,0,0,odf.CS),'contourf');
  setColorRange(flag{1});

  assert(strcmp(get(gca,'ColorScale'),'log'), ...
    'check_logColorScale: setColorRange(''%s'') did not switch the color scale', flag{1})

end

end
