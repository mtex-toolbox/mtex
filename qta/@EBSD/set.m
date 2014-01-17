function ebsd = set(ebsd,vname,value,varargin)
% set object variable to value
%
% Syntax
%   ebsd = set(ebsd,'vname',value)    %
%   ebsd = set(ebsd,'CS',symmetry)    % changes the crystal symmetry
%   ebsd = set(ebsd,'newfield',value) % adds |'newfield'| as an EBSD property, e.g. like MAD..
%
% Input
%  ebsd - @EBSD
%
% Options
%  phase - phase to consider
%  CS | SS - modify @symmetry
%  X - change spatial coordinates
%  orientations - set @orientation. Not recommend, should use the
%  [[EBSD.EBSD.html,EBSD]] constructor
%
% Output
% ebsd - the modified @EBSD object
%
% See also
% EBSD/get


if any(strcmp(vname,fields(ebsd)))
  
  if strcmp(vname,'CS')
    value = ensurecell(value);
    notIndexedPhase = ebsd.phaseMap(cellfun('isclass',ebsd.CS,'char'));
    notIndexed = ismember(ebsd.phaseMap,notIndexedPhase);
    
    if numel(value) == numel(ebsd.phaseMap)
    elseif (nnz(~notIndexed) == numel(value)) || numel(value) == 1
      value(~notIndexed) = value;
      value(notIndexed) = {'not indexed'};
    else
      error('The number of symmetries specified is less than the largest phase id.')
    end
  end
  
  ebsd.(vname) = value;
  
else
  
  ebsd = set@dynProp(ebsd,vname,value,varargin{:});
    
end

