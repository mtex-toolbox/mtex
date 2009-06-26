function [G,ind] = getgrid(ebsd,varargin)
% get mods of the components
%
%% Input
%  ebsd - @EBSD
%  ind - [double] indece to specific components (optional)
%
%% Output
%  G   - @SO3Grid of modal orientations

% no phases present
if length(ebsd) == 1
  G = ebsd.orientations;
  ind = true;
  return;
end

% phases present
phase = [ebsd.phase];
phases = unique(phase);

% check for phase
if check_option(varargin,'phase')
  
  ind = phase == get_option(varargin,'phase');
  
elseif numel(phases) > 1 && check_option(varargin,'CheckPhase')
  warning('MTEX:MultiplePhases','This operatorion is only permitted for a single phase! I''m going to process only the first phase.');
  ind = phase == phases(1);
else
  ind = true(numel(ebsd),1);
end

G = union(ebsd(ind).orientations); 
