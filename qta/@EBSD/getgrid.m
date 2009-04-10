function G = getgrid(ebsd,varargin)
% get mods of the components
%
%% Input
%  ebsd - @EBSD
%  ind - [double] indece to specific components (optional)
%
%% Output
%  G   - @SO3Grid of modal orientations

G = union(ebsd.orientations); 

phase = [ebsd.phase];

if ~isempty(phase) && check_option(varargin,'phase')
  
  sphase = get_option(varargin,'phase');
  ind = false(size(phase));
  
  for i = 1:length(sphase)
    ind = ind | phase == sphase(i);
  end
  
  G = subGrid(G,ind);
  
elseif check_option(varargin,'CheckPhase') && ...
    (~isempty(phase) || all(phase == phase(1)))
  warning('MTEX:MultiplePhases','Calculation includes multiple phases!');
end
