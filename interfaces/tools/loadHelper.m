classdef loadHelper < handle
% helps to load data-matrix with ColumnNames

properties
  data % (n x m) matrix
  unit
  opts
end

methods

  function loader = loadHelper(d, varargin)
    % Options
    %  KeepNaN -
    %  Radians -
    %  passive rotation -

    columnNames = stripws(lower(get_option(varargin,'ColumnNames')));
    columns = get_option(varargin,'Columns',1:length(columnNames));

    assert(length(columnNames) == length(columns), ...
      'Length of ColumnNames and Columns differ');

    [columnNames, m] = unique(columnNames);
    columns = columns(m);

    loader.data = array2table(d(:,columns),'variableNames',columnNames);

    % check some flags
    loader.unit = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});

    varargin = delete_option(varargin,{'ColumnNames','Columns'},1);
    loader.opts = delete_option(varargin,{'radians','radiant','radiand'});
    
  end

  function out = hasColumns(loader,names)
    out = all(cellfun(@(name) any(strcmpi(loader.data.Properties.VariableNames,name)),...
      stripws(ensurecell(names))));
  end

  function out = findColumn(loader,names)
    out = find(cellfun(@(x) any(strcmpi(stripws(ensurecell(names)),x)), ...
      loader.data.Properties.VariableNames),1);
  end

  function d = getColumnData(loader,colname)
    try
      pos = loader.findColumn(colname);
      d =  table2array(loader.data(:,pos));
      loader.data(:,pos) = [];
    catch
      error(['No data of type ' colname ' found'])
    end
  end

  function rot = getRotations(loader)

    conventions = {...
      {'Euler 1' 'Euler 2' 'Euler 3'};
      {'phi1','Phi','phi2'};
      {'alpha','beta','gamma'};
      {'Psi','Theta','Phi'};
      {'Psi','Theta','phi'};
      {'omega','Theta','phi'};
      {'Quat real','Quat i','Quat j','Quat k'}; };
    
    conventions = cellfun(@(s) stripws(lower(s)),conventions,'UniformOutput',false);

    convNames  = {...
      'Euler','Bunge', 'Matthies', 'Roe', 'Kocks', 'Canova', 'Quaternion' };

    type = find(cellfun(@(convention) loader.hasColumns(convention),conventions),1,'first');

    assert(~isempty(type),'At least specify three Euler angles or four quaternion components should be specified!');

    cols = conventions{type};

    % set rows where angle is 4*pi to nan
    ind = abs(table2array(loader.data(:,cols(1)))*loader.unit - 4*pi)<1e-3;
    loader.data(ind,cols) = {nan};

    % eliminate nans
    if ~check_option(loader.opts,'keepNaN')
      ind = any(isnan(table2array(loader.data(:,cols))),2);
      loader.data(ind,:) = [];
    end

    rotData = table2array(loader.data(:,cols));
    if type <=6
      flag = extract_option([convNames{type} loader.opts],convNames);     
      rot = rotation.byEuler(rotData * loader.unit, flag{:});
    else
      rot = rotation(quaternion(rotData));
    end

    if check_option(loader.opts,{'passive','passive rotation'})
      rot = inv(rot);
    end

    % remove columns
    loader.data(:,cols) = [];

  end

  function v = getVector3d(loader)

    conventions = {...
      {'x','y','z'};...
      {'Polar' 'Azimuth'};
      {'Polar Angle' 'Azimuth Angle'};
      {'Colatitude','Longitude'};
      {'Colattitude','Longitude'}; % for historical reasons
      {'Latitude','Longitude'};
      {'Lattitude','Longitude'};   % for historical reasons
      };
    conventions = cellfun(@(s) stripws(lower(s)),conventions,'UniformOutput',false);

    type = find(cellfun(@(convention) loader.hasColumns(convention),conventions),1,'first');

    assert(~isempty(type),'Columns for cartesian or spherical coordinates not specoified!');

    cols = conventions{type};

    % eliminate nans
    if ~check_option(loader.opts,'keepNaN')
      loader.data(any(isnan(table2array(loader.data(:,cols))),2),:) = [];
    end

    % specimen directions
    if type == 1  % xyz
      v = vector3d(table2array(loader.data(:,cols)));
    else % spherical

      theta = table2array(loader.data(:,cols(1))) * loader.unit;
      rho   = table2array(loader.data(:,cols(2))) * loader.unit;
            
      if type >= 6, theta = pi/2 - theta; end % latitude

      v = vector3d.byPolar(theta,rho);

    end

    % remove columns
    loader.data(:,cols) = [];

  end

  function options = getOptions(loader,varargin)    

    % maybe we should ignore some columns
    cols = ensurecell(get_option(varargin,'ignoreColumns',[]));
    for k = 1:length(cols)
      try
        loader.data(:,cols{k}) = [];
      end
    end

    options = table2struct(loader.data,'ToScalar',true);
  end

  function xyz = getPos(loader)

    if loader.hasColumns({'x','y','z'})
      xyz = vector3d(table2array(loader.data(:,{'x','y','z'})));
      loader.data(:,{'x','y','z'}) = [];
    elseif loader.hasColumns({'x','y'})
      xyz = vector3d(table2array(loader.data(:,'x')), table2array(loader.data(:,'y')),0);
      loader.data(:,{'x','y'}) = [];
    else 
      error('No columns with "x" and "y" coordinates found!')
    end
  end
end

end
