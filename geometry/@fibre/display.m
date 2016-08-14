function display(f,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('fibre_index','fibre') ...
    ' ' docmethods(inputname(1))]);
end

disp([' size: ' size2str(f)]);

% display symmetry
if isa(f.CS,'crystalSymmetry')
  if ~isempty(f.CS.mineral)
    disp([' mineral: ',char(f.CS,'verbose')]);
  else
    disp([' symmetry: ',char(f.CS,'verbose')]);
  end
end

if f.antipodal, disp(' antipodal: true'); end

return

if length(f)>50, return; end

f = 1;

% display coordinates
if isa(f.CS,'crystalSymmetry')
  if any(strcmp(f.b.CS.lattice,{'hexagonal','trogonal'}))
    d = [f.b.UVTW f.n.hkl];
    d(abs(d) < 1e-10) = 0;
    cprintf(d,'-L','  ','-Lc',{'U' 'V' 'T' 'W' '| H' 'K' 'I' 'L'});
  else
    d = [f.b.uvw f.n.hkl];
    d(abs(d) < 1e-10) = 0;
    cprintf(d,'-L','  ','-Lc',{'u' 'v' 'w' '| h' 'k' 'l'});
  end
else
  d = round(100*[f.b.xyz f.n.xyz])./100;
  d(abs(d) < 1e-10) = 0;
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z' ' |   x' 'y' 'z' });
end

return


% display coordinates
if ~check_option(varargin,'skipCoordinates') && ...
    (check_option(varargin,'all') || (length(f) < 20 && ~isempty(f)))
  
  d = [f.x(:),f.y(:),f.z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end
