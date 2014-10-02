function ori = loadOrientation_DRex(fname,varargin)

ori = orientation;

if ~exist(fname,'file'), error(['File ' fname ' not found!']);end

% if check then restrict range
if check_option(varargin,'check')
  options = {'RowRange',[1 100]};
else
  options = {};
end

try

  % load data
  d = txt2mat(fname,options{:},'InfoLevel',0);

  % assert size
  assert(size(d,2)==9);

  % reshape as matrices
  d = reshape(d',[3,3,size(d,1)]);
  
  % check for orthogonality
  if check_option(varargin,'check')
    for i = 1:size(d,3)
      assert(norm(d(:,:,i) * d(:,:,i)'-eye(3))<1e-2);
    end
    
    % if everything is correct return with no error
    return
  end
     
  % compute orientations
  d = permute(d,[2,1,3]);
  %d = flipdim(d,1);
  d = flipdim(d,2);
  CS = getClass(varargin,'crystalSymmetry',crystalSymmetry);
  SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);
  ori = orientation('matrix',CS,SS);
    
  
catch %#ok<CTCH>
  interfaceError(fname)  
end
