function display(f,varargin)
% standard output


refSystems = [char(f.CS,'compact') ' ' char(8594) ' ' char(f.SS,'compact')];

displayClass(f,inputname(1),'fibre',varargin{:},'moreInfo',refSystems);

if length(f)~=1, disp([' size: ' size2str(f)]); end

% display symmetry
%dispLine(f.CS);
%dispLine(f.SS);

if f.antipodal, disp(' antipodal: true'); end
disp(' ');

if length(f)~=1, return; end

disp([' h || r: ' char(round(f.h)) ' || (' char(round(f.r)) ')']);

% display starting and end orientation
if angle(f.o2,f.o1,'noSymmetry')>0
  disp([' o1 -> o2: ' char(f.o1) ' -> ' char(f.o2)]);
end

end

