function out = eq(S1,S2,varargin)
% check S1 == S2

if length(S1) ~= length(S2)
  
  out  = false;
  return;
  
elseif isa(S1,'char') && isa(S2,'char')
  
  out = strmpi(S1,S2);
  return;
  
end

out = eq@handle(S1,S2);

% just compare handles -> this is fastest
if out || (nargin == 3 && islogical(varargin{1}) && varargin{1}), return; end

if ~isa(S1,'crystalSymmetry') || ~isa(S2,'crystalSymmetry')
  % one of the two is not a crystal symmetry

  try
    out = S1.Laue.id == S2.Laue.id;
  catch
    out = false;
  end

elseif S1.id == 0
      
  out = S2.id == 0 && numSym(S1) == numSym(S2) && ...
    max(angle(S1.rot(:),S2.rot(:)))<0.1 *degree;
      
else
  
  out = S1.id == S2.id && ...
    all(norm(S1.axes - S2.axes)./norm(S1.axes)<5*10^-2);

  if ~isempty(S1.mineral) && ~isempty(S2.mineral)
    out = out && strcmpi(S1.mineral,S2.mineral);
  end

end
