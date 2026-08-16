function display(cF,varargin)
% standard output

% the mineral and the convention go in the header, as for every other
% reference frame - the lattice below is the detail
info = {};
if ~isempty(cF.name), info{end+1} = cF.name; end %#ok<AGROW>
if isa(cF.how2plot,'plottingConvention')
  info{end+1} = conventionChar(cF); %#ok<AGROW>
end

displayClass(cF,inputname(1),'moreInfo',strjoin(info,', '),varargin{:});

disp(['  ' strjoin(cF.axesNames,', ') '  : ' xnum2str(cF.abc)]);

abg = cF.abg;
if any(abs(abg - pi/2) > 1e-6)
  disp(['  α, β, γ  : ' xnum2str(abg./degree) '°']);
end

align = alignment(cF);
if ~isempty(align)
  disp(['  alignment: ' strjoin(align,', ')]);
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
