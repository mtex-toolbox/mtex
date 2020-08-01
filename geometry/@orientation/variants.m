function out = variants(p2c,varargin)
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
%  oriChild  - child @orientation
%  variantId - id of the variant
%
% Options
%  parent - return parent variants
%  child  - return child variants (default)
%
% Output
%  p2cVariants - parent to child variants
%  oriParent - parent @orientation
%  oriChild  - child @orientation
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
if nargin>1 && isa(varargin{1},'orientation')
  
  if eq(varargin{1}.CS,p2c.CS,'Laue')
    
    oriParent = varargin{1};
    varargin(1) = [];
    parentVariants = false;
    
  elseif eq(varargin{1}.CS,p2c.SS,'Laue')
  
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
  
  if eq(varargin{1}.CS,p2c.CS,'Laue')
    
    MillerParent = varargin{1};
    varargin(1) = [];
    parentVariants = false;
    
  elseif eq(varargin{1}.CS,p2c.SS,'Laue')
  
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
  p2cVariants = p2c.SS * p2c;
  
  % ignore all variants symmetrically equivalent with respect to the parent
  % symmetry
  p2cVariants.SS = crystalSymmetry;
  p2cVariants = unique(p2cVariants);
  p2cVariants.SS = p2c.SS;

  if exist('variantId','var')
    p2cVariants = p2cVariants.subSet(variantId);
  end
  
  if exist('oriChild','var')
    out = oriChild .* p2cVariants;
  elseif exist('MillerChild','var')
    out = inv(p2cVariants) * MillerChild; %#ok<MINV>
  else
    out = p2cVariants;
  end

else % child variants
  
    % symmetrise with respect to child symmetry
  p2cVariants = p2c * p2c.CS;
  
  % ignore all variants symmetrically equivalent with respect to the child
  % symmetry
  p2cVariants.CS = crystalSymmetry;
  p2cVariants = unique(p2cVariants);
  p2cVariants.CS = p2c.CS;
  
  if exist('variantId','var')
    p2cVariants = reshape(p2cVariants.subSet(variantId),size(variantId));
  end
  
  if exist('oriParent','var')
    out = oriParent .* inv(p2cVariants);
  elseif exist('MillerParent','var')
    out = p2cVariants * MillerParent;
  else
    out = p2cVariants;
  end
end
