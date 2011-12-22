function T = tensor(M,varargin)
% constructor
%
% *tensor* is the low level constructor for a *tensor* object. 
% For importing real world data you might want to use the *import_wizard*.
%
%% Syntax
%  T = tensor(M,CS,'name',name,'unit',unit,'propertyname',property)
%
%% Input
%  M  - matrix of tensor entries
%  CS - crystal @symmetry
%
%% Options
%  rank - rank of the tensor
%  unit - physical unit of the entries
%  name - name of the tensor
%
%% See also
% ODF/calcTensor EBSD/calcTensor

% conversion from vector3d
if isa(M,'vector3d')
  
  T.M = shiftdim(double(M),ndims(M));
  r = 1;

% conversion from quaternion
elseif isa(M,'quaternion')

  T.M = matrix(M);
  r = 2;
  
else

  % get the tensor entries
  T.M = M;

  % consider the case of a row vector, which is most probably a 1-rank tensor
  if ndims(T.M)==2 && size(T.M,1)==1 && size(T.M,2) > 1 && ...
      ~check_option(varargin,'rank')
  
    disp(' ');
    warning(['I guess you want to define a rank one tensor. ' ...
      'However, a rank one tensor is always a column vector, but ' ...
      'you specified a row vector. ',...
      'I''m going to transpose you vector.']);
  
    T.M = T.M.';
  
  end

  % transform from voigt matrix representation to ordinary rank four tensor
  if numel(T.M) == 36,
    T.M = tensor24(T.M);
  elseif numel(T.M) == 18,
    T.M = tensor23(T.M,check_option(varargin,'doubleconvention'));
  end

  % compute the rank of the tensor by finding the last dimension
  % that is length grater then one
  r = max([1,find(size(T.M)-1,1,'last')]);
  
end
  
T.properties = struct;
T.rank    = get_option(varargin,'rank',r);
varargin = delete_option(varargin,'rank');

% extract symmetry
args = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));
if ~isempty(args)
  T.CS = varargin{args};
  varargin(args) = [];
else
  T.CS = symmetry;
end

%
if check_option(varargin,'doubleconvention')
  T.properties.doubleconvention = 'true';
end


varargin = delete_option(varargin,{'doubleconvention','singleconvention','InfoLevel'});

%
if check_option(varargin,'doubleconvention')
  T.properties.doubleconvention = 'true';
end


varargin = delete_option(varargin,{'doubleconvention','singleconvention','InfoLevel'});

% extract properties
while ~isempty_cell(varargin)  
  T.properties.(varargin{1}) = varargin{2};
  varargin = varargin(3:end);
end

% setup tensor
superiorto('quaternion','rotation','orientation')
T = class(T,'tensor');

if ~check_option(varargin,'noCheck')
  check_symmetry(T)
end


function check_symmetry(T)

rot = rotation(T.CS);

for i = 2:length(rot)
  
  if T ~= rotate(T,rot(i))
    warning('MTEX:tensor','Tensor does not pose the right symmetry');
    return;
  end  
end
