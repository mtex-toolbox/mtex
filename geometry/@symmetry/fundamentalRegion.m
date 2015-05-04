function  oR = fundamentalRegion(cs,varargin)
% get the fundamental sector for a symmetry in the inverse pole figure
%
% Syntax
%   oR = fundamentalRegion(cs)
%   oR = fundamentalRegion(cs1,cs2)
%
% Input
%  cs,cs1,cs2 - @symmetry
%
% Ouput
%  sR - @orientationRegion
%
% Options
%  invSymmetry - wheter mori == inv(mori)
%

% maybe there is nothing to do
if check_option(varargin,'complete')
  oR = orientationRegion(varargin{:});
  return
end

[axes,angle] = getMinAxes(cs);

rot = rotation('axis',[axes(:);-axes(:)],'angle',[angle(:);angle(:)]./2);

h = Rodrigues(rot);

% sort by length
[~,ind] = sort(norm(h));
h = h(ind);

% some may not be active
hh = vector3d;
for i = 1:length(h)
  
  if all(dot(h(i),hh)+1e-5<norm(hh).^2)
    hh = [hh,h(i)]; %#ok<AGROW>
  end
    
end



oR = oR.cleanUp;

