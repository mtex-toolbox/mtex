function [v,l] = symmetrise(v,S,varargin)
% symmetrcially equivalent directions and its multiple
%
% Input
%  v - @vector3d
%  S - @symmetry
%
% Flags
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  skipAntipodal - do not include antipodal symmetry
%
% Output
%  Sv - symmetrically equivalent vectors
%  l  - number of symmetrically equivalent vectors

% TODO
% symmetrise behaviour for case 1 and option 'antipodal' is not very
% intuitive
% we should use the option unique to get the unique symmetric equivalent!!



v = S.rot * v;
  
if ~S.isLaue && (check_option(varargin,'antipodal') || v.antipodal) ...
    && ~check_option(varargin,'skipAntipodal') %#ok<BDLGI>
  v = [v;-v];
  
  if check_option(varargin,'plot')
    del = v.z<-1e-6;
    v.x(del) = [];
    v.y(del) = [];
    v.z(del) = [];
  end
end

if check_option(varargin,'unique')
  
  if check_option(varargin,{'keepAntipodal'})
    ap = {};
  else
    ap = {'antipodal'};
  end
  
  vSym = cell(size(v,2),1);
  dim1 = size(v,1);
  for j = 1:size(v,2)
    vSym{j} = unique(v.subSet((1:dim1) + (j-1)*dim1),'noSymmetry',ap{:});
  end

  l  = cellfun(@length, vSym);
  v = vertcat(vSym{:});
  
else
  
  

end
