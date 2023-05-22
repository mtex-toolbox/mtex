function [v,l,sym] = symmetrise(v,varargin)
% symmetrcially equivalent directions and its multiple
%
% Syntax
%   vSym = symmetrise(v,S)
%
%   % include antipodal symmetry
%   vSym = symmetrise(v,S,'antipodal')
%
%   % exclude antipodal symmetry
%   vSym = symmetrise(v,S,'noAntipodal')
%
%   % every symmetrically equivalent direction only once 
%   [vSym,l,sym] = symmetrise(v,S,'unique')
%
%   % every symmetrically equivalent axis only once 
%   [vSym,l,sym] = symmetrise(v,S,'unique','noAntipodal')
%
% Input
%  v - @vector3d
%  S - @symmetry
%
% Output
%  vSym - S * v  @vector3d
%  l    - multiplicity of the crystal directions
%  sym  - @rotation
%
% Flags
%  antipodal   - include <VectorsAxes.html antipodal symmetry>
%  noAntipodal - do not include antipodal symmetry (without option unique)
%  noAntipodal - do not remove antipodal vectors (with option unique)
%  unique      - only return distinct axes or directions (noAntipodal)
%

% Example
% Input: sym = 112           (100), (001)
% no option               -> (100)(-100), (001)(001) 
% unique                  -> (100)(-100), (001)
% antipodal               -> (100)(-100)(-100)(100),(001)(001)(00-1)(00-1)
% antipodal + unique      -> (100), (001)
% antipodal + noAntipodal + unique  -> (100)(-100), (001)(00-1)
%
% cs = crystalSymmetry('112')
% m = Miller({1,0,0},{0,0,1},cs)
% symmetrise(m)

if nargin > 1 && isa(varargin{1},'symmetry')
  S = varargin{1};
  varargin(1) = [];
else
  S = specimenSymmetry;
end


% symmetrisation includes antipodal symmetry?
antiSym = check_option(varargin,'antipodal') || v.antipodal || S.isLaue;

% there is no need to add antipodal symmetry twice
if antiSym, S = S.properGroup; end

if check_option(varargin,'unique')

  % shall we use unique with antipodal?
  if (check_option(varargin,'antipodal') || v.antipodal) ...
      && ~check_option(varargin,'noAntipodal') 
  
    % if yes -> no antipodal symmetrisation needed
    antiSym = false;
    apUnique = 'antipodal';
    
  else
    
    % ensure unqiue ignores "antipodal"
    apUnique = 'noAntipodal';
    
  end  
else
  
  % noAntipodal switches off antipodal
  antiSym = antiSym && ~check_option(varargin,'noAntipodal');
  
end

% symmetrise with respect to symmetry
v = S.rot * v;

% consider antipodal symmetry
%if antiSym && ~S.isLaue, v = [v;-v]; end
if antiSym && ~S.isLaue, v = reshape([1;-1] * reshape(v,1,[]),2*S.numSym,[]); end

% finally ensure unqiue vectors if required
if check_option(varargin,'unique')
  
  vSym = cell(size(v,2),1);
  idSym = cell(size(v,2),1);
  dim1 = size(v,1);
  for j = 1:size(v,2)
    [vSym{j},idSym{j}] = unique(v.subSet(((1:dim1) + (j-1)*dim1).'),'noSymmetry',apUnique,'stable');
  end

  l  = cellfun(@length, vSym);
  v = vertcat(vSym{:});
  if nargout == 3, sym = S.rot(vertcat(idSym{:})); end
  
end

% where it is used
% calcPDF              ->  
% Miller/scatter       -> noAntipodal   as antipodal is treated by vector3d/scatter
% checkZeroRange       ->  
% Miller/multiplicity  ->
% Miller/text          -> noAntipodal
% fibre/symmetrise     -> 
% SO3FunRBF/calcPDF    -> noAntipodal
