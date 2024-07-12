function [out, bestFriends] = variants(p2c,varargin)
% variants parent to child orientation relationship
%
% Syntax
%
%   p2cVariants = variants(p2c, 'child')
%   p2cVariants = variants(p2c, 'parent')
%
%   % compute all child variants
%   oriChild = variants(p2c, oriParent)
%
%   % compute child variants specified by variantId
%   oriChild = variants(p2c, oriParent, variantId)
%
%   % compute transformation ODF
%   odfChild = variants(p2c, odfParent)
%
%   % compute all parent variants
%   oriParent = variants(p2c, oriChild)
%
%   % compute parent variants specified by variantId
%   oriParent = variants(p2c, oriChild, variantId)
%
% Input
%
%  p2c - parent to child @orientation relationship
%  oriParent - parent @orientation
%  odfParent - parent ODF @SO3Fun
%  hklParent - parent direction @Miller
%  oriChild  - child @orientation
%  hklChild  - child direction @Miller
%  variantId - id of the variant
%
% Options
%  parent - return parent variants
%  child  - return child variants (default)
%
% Output
%  p2cVariants - parent to child variants
%  oriParent - parent @orientation (numOri x numVariants)
%  hklParent - parent directions (numOri x numVariants)
%  oriChild  - child @orientation  (numOri x numVariants)
%  hklChild  - child directions (numOri x numVariants)
%  odfPChild - child ODF @SO3Fun
%
% Example
%   % parent symmetry
%   cs_fcc = crystalSymmetry('432', [3.6599 3.6599 3.6599], 'mineral', 'Iron fcc');
%
%   % child symmetry
%   cs_bcc = crystalSymmetry('432', [2.866 2.866 2.866], 'mineral', 'Iron bcc')
%
%   % define a fcc parent orientation
%   ori_fcc = orientation.brass(cs_fcc)
%
%   % define Nishiyama Wassermann fcc to bcc orientation relation ship
%   NW = orientation.NishiyamaWassermann(cs_fcc,cs_bcc)
%
%   % compute a bcc child orientation related to the fcc orientation
%   ori_bcc = ori_fcc * inv(NW)
%
%   % compute all symmetrically possible child orientations
%   ori_bcc = unique(ori_fcc.symmetrise * inv(NW))
%
%   % same using the function variants
%   ori_bcc2 = variants(NW,ori_fcc)
%
%   % we may also compute all possible child to child misorientations
%   bcc2bcc = unique(variants(NW,'child') * inv(NW))
%
% See also
% calcParents

% browse input
if nargin>1 && isa(varargin{1},'SO3Fun')

  out = transformODF(varargin{1},p2c,varargin{2:end});
  return

elseif nargin>1 && isa(varargin{1},'orientation')
  
  if varargin{1}.CS.Laue == p2c.CS.Laue
    
    oriParent = varargin{1};
    varargin(1) = [];
    parentVariants = false;
    
  elseif varargin{1}.CS.Laue == p2c.SS.Laue
  
    oriChild = varargin{1};
    varargin(1) = [];
    parentVariants = true;
    
  elseif isempty(varargin{1})
    
    out = orientation(p2c.CS);
    return;
    
  else
    error('Symmetry mismatch!')
  end
 
elseif nargin>1 && isa(varargin{1},'Miller')
  
  if varargin{1}.CS.Laue == p2c.CS.Laue
    
    MillerParent = varargin{1};
    varargin(1) = [];
    parentVariants = false;
    
  elseif varargin{1}.CS.Laue == p2c.SSLaue
  
    MillerChild = varargin{1};
    varargin(1) = [];
    parentVariants = true;
       
  else
    error('Symmetry mismatch!')
  end

else
  parentVariants = check_option(varargin,'parent');
end

if ~isempty(varargin) && isnumeric(varargin{1}), variantId = varargin{1}; end

if parentVariants % parent variants

  % symmetrise with respect to child symmetry
  p2cVariants = p2c.SS.properGroup.rot * p2c;
  
  % ignore all variants symmetrically equivalent with respect to the parent symmetry
  ind = ~any(tril(dot_outer(p2cVariants,p2cVariants,'noSym2')>1-1e-4,-1),2);
  p2cVariants = p2cVariants.subSet(ind);
  
  if exist('variantId','var')
    p2cVariants = reshape(p2cVariants.subSet(variantId),size(variantId));
  else
    p2cVariants = reshape(p2cVariants,1,[]);
  end
  
  if exist('oriChild','var')
    out = reshape(oriChild,[],1) .* p2cVariants;
  elseif exist('MillerChild','var')
    out = inv(p2cVariants) * MillerChild; %#ok<MINV>
  else
    out = p2cVariants;
  end

else % child variants
  
  %DC = disjoint(p2c.SS, p2c * p2c.CS.rot * inv(p2c));
  %DP = disjoint(p2c.CS, inv(p2c) * p2c.SS.rot * p2c);
  %csRot = orientation(p2c.CS.rot,DP);
  %ind = ~any(tril(dot_outer(csRot,csRot)>1-1e-4,-1),2);
  %p2cVariants1 = p2c * subSet(p2c.CS.rot,ind);
  
  
  % symmetrise with respect to parent symmetry
  symRot = p2c.CS.properGroup.rot;
  % try to switch to Morito convention
  if length(symRot) == 24
    symRot = symRot([1 17 2 16 3 18 8 22 9 24 7 23 19 11 20 10 21 12 6 15 4 14 5 13]);
  end
    
  p2cVariants = p2c * symRot;
  
  % ignore all variants symmetrically equivalent with respect to the child symmetry
  ind = ~any(tril(dot_outer(p2cVariants,p2cVariants,'noSym1')>1-1e-4,-1),2);
  p2cVariants = p2cVariants.subSet(ind);

  if isfield(p2c.opt,'variantMap') && length(p2c.opt.variantMap) == length(p2cVariants)
    p2cVariants = p2cVariants.subSet(p2c.opt.variantMap);
  end
  
  if exist('variantId','var')
    p2cVariants = reshape(p2cVariants.subSet(variantId),size(variantId));
  else
    p2cVariants = reshape(p2cVariants,1,[]);
  end
  
  if exist('oriParent','var')
    out = reshape(oriParent.project2FundamentalRegion,[],1) .* inv(p2cVariants);
  elseif exist('MillerParent','var')
    out = p2cVariants .* reshape(MillerParent,[],1);
  else
    out = p2cVariants;
  end
end

if nargout == 2
  [~,bestFriends] = max(angle_outer(out,out,'noSym2') < 8*degree,[],2);
end
