function loader = loadHelper( d, varargin )
% helps to load data-matrix with ColumnNames
% restricts also data according to conventions (e.g. >4pi)
%
% Input
%  d -  (n x m) matrix
%  ColumnNames - (1 x m) cell of names
%  Columns - (1 x m) cell of ColumnNames indizes
%
% Options
%  KeepNaN - 
%  Radians - 
%  passive rotation - 
%
% Output
%  loader  - structure with some funs
%


data = d;

opts = localParseArgs(varargin{:});

loader.getRotations  = @getRotations;
loader.getVector3d   = @getVector3d;
loader.getOptions    = @getOptions;
loader.hasColumn     = @hasColumn;
loader.getColumnData = @getColumnData;


  function b = hasColumn(colname)

    b = opts.hasMandatory(colname);

  end

  function d = getColumnData(colname)

    d =  data(:,opts.getColumns(colname));

  end

  function q = getRotations()

    conventions = {...
      {'Euler 1' 'Euler 2' 'Euler 3'};
      {'phi1','Phi','phi2'};
      {'alpha','beta','gamma'};
      {'Psi','Theta','Phi'};
      {'Psi','Theta','phi'};
      {'omega','Theta','phi'};
      {'Quat real','Quat i','Quat j','Quat k'}; };
    convNames  = {...
      'Euler','Bunge', 'Matthies', 'Roe', 'Kocks', 'Canova', 'Quaternion' };

    type = find(cellfun(@(x) opts.hasMandatory(x),conventions),1,'first');

    if ~isempty(type)

      cols = opts.getColumns(conventions{type});

      opts.ColumnNames = delete_option(opts.ColumnNames, ...
        strrep(lower(conventions{type}),' ',''));

      %extract options
      dg = opts.Unit;

      % eliminate nans
      if ~check_option(opts.Options,'keepNaN')
        data(any(isnan(data(:,cols)),2),:) = [];
      end

      % eliminate rows where angle is 4*pi
      ind = abs(data(:,cols(1))*dg-4*pi)<1e-3;
      data(ind,:) = [];

      if type <=6
        flag = extract_option([convNames{type} opts.Options],convNames);
        q = rotation.byEuler(data(:,cols(1))*dg,data(:,cols(2))*dg,data(:,cols(3))*dg,...
          flag{:});
      else
        q = rotation('quaternion',...
          data(:,cols(1)),data(:,cols(2)),data(:,cols(3)),data(:,cols(4)));
      end

      if check_option(opts.Options,{'passive','passive rotation'})
        q = inv(q);
      end

    else

      error('You should at least specify three Euler angles or four quaternion components!');

    end

  end

  function v = getVector3d()

    conventions = {...
      {'Polar Angle' 'Azimuth Angle'};
      {'Colatitude','Longitude'};
      {'Colattitude','Longitude'}; % for historical reasons
      {'Latitude','Longitude'};
      {'Lattitude','Longitude'};   % for historical reasons
      {'x','y','z'};};

    type = find(cellfun(@(x) opts.hasMandatory(x),conventions),1,'first');


    if ~isempty(type)

      cols = opts.getColumns(conventions{type});

      opts.ColumnNames = delete_option(opts.ColumnNames, ...
        strrep(lower(conventions{type}),' ',''));

      % eliminate nans
      data(any(isnan(data(:,cols)),2),:) = [];

      % specimen directions
      if type == 6  % xyz

        v = vector3d(data(:,cols).');

      else % spherical

        theta = data(:,cols(1))*opts.Unit;
        rho   = data(:,cols(2))*opts.Unit;

        if type >= 4 % latitude
          theta = pi/2 - theta;
        end

        v = vector3d.byPolar(theta,rho);

      end

    else

      error('MTEX:MISSINGDATA',...
        'You should at least specify the columns of the spherical of cartesian coordinates');

    end

  end

  function options = getOptions(varargin)

    opts.ColumnNames = delete_option(opts.ColumnNames,...
      get_option(varargin,'ignoreColumns',[]));

    optdata = getColumnData(opts.ColumnNames);

    options = [opts.ColumnNames(:)';
      mat2cell(optdata,size(optdata,1),ones(1,size(optdata,2)))];

    options = struct(options{:});

  end


end


function params = localParseArgs(varargin)

columnNames = lower(get_option(varargin,'ColumnNames'));
columns = get_option(varargin,'Columns',1:length(columnNames));

assert(length(columnNames) == length(columns), 'Length of ColumnNames and Columns differ');

[columnNames, m] = unique(columnNames);
columns = columns(m);

columnNames = stripws(columnNames(:));

hasMandatoryCol = @(a) all(cellfun(@(x) any(find(strcmpi(stripws(columnNames),stripws(x)))),ensurecell(a)));
layoutCol       = @(a) columns(cell2mat(...
  cellfun(@(x) find(strcmpi(stripws(columnNames),stripws(x))),...
  reshape(ensurecell(a),[],1),'UniformOutput',false)));

% check some flags
unit = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});

varargin = delete_option(varargin,{'ColumnNames','Columns'},1);
varargin = delete_option(varargin,{'radians','radiant','radiand'});


params.ColumnNames       = columnNames;
params.hasMandatory      = hasMandatoryCol;
params.getColumns        = layoutCol;
params.Unit              = unit;
params.Options           = varargin;

  function str = stripws(str)

    str = strrep(str,' ','');

  end

end
