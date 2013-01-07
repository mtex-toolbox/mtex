function ebsd = loadEBSD_DRex(fname,varargin)

if ~exist(fname,'file')
  error(['File ' fname ' not found!']);
end

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
  
  % set default values for the crystal and specimen symmetry
  cs = get_option(varargin,'CS',symmetry('cubic'));
  ss = get_option(varargin,'SS',symmetry('-1'));
  
  % compute orientations
  d = permute(d,[2,1,3]);
  %d = flipdim(d,1);
  d = flipdim(d,2);
  ori = orientation('matrix',d,cs,ss);
  
  % set up EBSD object
  ebsd = EBSD(ori);
  
catch %#ok<CTCH>
  interfaceError(fname)  
end
