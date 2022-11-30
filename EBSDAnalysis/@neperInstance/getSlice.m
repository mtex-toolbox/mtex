function grains = getSlice(this,varargin)
%
% TODO: better docu, ohne default, 
% Input (optional)
%  n - slice normal @vector3d (default:[1,1,1])
%  d - point in slice @vector3d
%      0 > x,y,z < 1
%      or scalar d of a plane(a,b,c,d) (default:1)

%%
%deleting old files, to make shure, to not load a wrong file, if slicing failed
warning off MATLAB:DELETE:FileNotFound
delete([this.fileName2d '.tess' ]);
delete([this.fileName2d '.ori' ]);
warning on MATLAB:DELETE:FileNotFound

    %% default values
    n=vector3d(1,1,1);
    d=1;

    if nargin>1
      if isa(varargin{1},'vector3d')
        n=varargin{1};
        n=normalize(n);
      else
        warning 'argument error, using default n'
      end
    end
    if nargin>2
      if isa(varargin{2},"vector3d")
        d=dot(n,varargin{2});
      elseif isnumeric(varargin{2}) && isscalar(varargin{2})
        d=varargin{2};
      else
        warning 'argument error, using default'
      end
    end

    %% get a slice
    system([this.cmdPrefix 'neper -T -loadtess ' this.fileName3d '.tess ' ...
      '-transform "slice(' num2str(d) ',' num2str(n.x) ',' num2str(n.y) ',' num2str(n.z) ')" ' ... % this is (d,a,b,c) of a plane
      '-ori "file(' this.fileName3d '.ori)" ' ...
      '-o ' this.fileName2d ' ' ...
      '-oriformat geof ' ...
      '-oridescriptor rodrigues ' ...
      '-format tess,ori ' ...
      '&& ' ...
      ...
      this.cmdPrefix 'neper -V ' this.fileName2d '.tess']);

    if ~isfile('2dslice.tess')
      error 'slicing failed, try other plane parameters.'
    end

    grains = grain2d.load([this.fileName2d '.tess']);

  end