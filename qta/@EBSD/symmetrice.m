function ebsd = symmetrice(ebsd,cs)
% change the crystal symmetry of EBSD data
%
%% Description
%
% The only purpose of this function up to now, is to switch between
% different crystallographic setups of the trigonal crystal symmetry. Other
% functionality might by included in the future.
%
%% Input
%  ebsd - @EBSD
%  cs   - new crystal @symmetry
%
%% Output
%  ebsd - @EBSD
%
%% See also
%  CrystalSymmetries

% handle multiple phases
if length(ebsd) > 1
  for i = 1,length(ebsd), ebsd(i) = symmetrice(ebsd(i));end
  return
end

% 
if ~any(strcmpi(Laue(get(ebsd,'CS')),{'3m','-3m'})) || ~any(strcmpi(Laue(cs),{'3m','-3m'}))
  error('symmetrice does support only trigonal symmetry');
end

if get(get(ebsd,'CS'),'alignment') > get(cs,'alignment')

  ebsd.orientations = ebsd.orientations * axis2quat(zvector,30*degree);

elseif get(get(ebsd,'CS'),'alignment') < get(cs,'alignment')
  
  ebsd.orientations = ebsd.orientations * axis2quat(zvector,-30*degree);
  
else
  
  warning('MTEX:symmetrice','symmetry alignment is equal');
  
end

ebsd.orientations = set(ebsd.orientations,'CS',{cs});
ebsd.CS = cs;  
  
