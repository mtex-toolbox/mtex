function [CS,SS] = extractSymmetries(varargin)
% extract crystal and specimen symmetry from input arguments

%CS = getClass(varargin,'crystalSymmetry',crystalSymmetry);
%SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);

ind = find(cellfun(@(cs) isa(cs,'symmetry'),varargin));

if any(ind)
  CS = varargin{ind(1)};
else
  CS = crystalSymmetry;
end

if numel(ind)==2
  SS = varargin{ind(2)};
elseif numel(ind)>2
  error('To many symmetries specified');
else
  SS = specimenSymmetry;
end
