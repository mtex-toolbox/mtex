function display(cF,varargin)
% standard output

displayClass(cF,inputname(1),varargin{:});

if ~isempty(cF.name), disp(['  mineral  : ' cF.name]); end

disp(['  ' strjoin(cF.axesNames,', ') '  : ' xnum2str(cF.abc)]);

abg = cF.abg;
if any(abs(abg - pi/2) > 1e-6)
  disp(['  α, β, γ  : ' xnum2str(abg./degree) '°']);
end

align = alignment(cF);
if ~isempty(align)
  disp(['  alignment: ' strjoin(align,', ')]);
end

if isa(cF.how2plot,'plottingConvention')
  disp(['  how2plot : ' conventionChar(cF)]);
end

disp(' ');

end

% =========================================================================
function c = conventionChar(cF)
% the convention expressed in crystal directions, e.g. '⊙c*→a' - the c*
% axis points out of the screen, the a axis east; falls back to the
% Cartesian form when no crystal axis matches the screen directions

pC = cF.how2plot;

dirs = normalize([cF.basis, basisDual(cF)]);
names = [cF.axesNames, strcat(cF.axesNames,'*')];

out = matchAxis(pC.outOfScreen,dirs,names);
east = matchAxis(pC.east,dirs,names);

if isempty(out) || isempty(east)
  c = char(pC,'compact');
else
  c = ['⊙' out '→' east];
end

end

function name = matchAxis(v,dirs,names)

name = '';
a = angle(v,dirs);
[m,i] = min(a);
if m < 1e-4
  name = names{i};
elseif pi - max(a) < 1e-4
  [~,i] = max(a);
  name = ['-' names{i}];
end

end
