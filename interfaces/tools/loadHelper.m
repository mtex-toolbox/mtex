classdef loadHelper < handle
% helps to load a data matrix with column names
%
% Wraps the numeric matrix an importer has read together with the names of
% its columns, so that the interface can ask for 'phi1' or 'mad' instead of
% a column index. The matrix itself is never copied.
%
% Syntax
%   loader = loadHelper(d,'ColumnNames',names)
%   loader = loadHelper(d,'ColumnNames',names,'Columns',cols,'radians')
%
% Input
%  d     - numeric data matrix
%  names - cell list of column names
%  cols  - which physical column each name refers to
%
% Output
%  loader - @loadHelper
%
% Options
%  radians - angles are in radians rather than degree
%
% Class Properties
%  data        - the numeric matrix, unchanged
%  colMap      - physical column in data for each logical column
%  columnNames - the column names, lower case and without whitespace
%  unit        - the angle unit of the data
%
% See also
% EBSD.load PoleFigure.load
%

properties
  data         % (n × M) numeric matrix, UNveraendert (copy-on-write geteilt)
  colMap       % 1 × m: physische Spalte in data je logischer Spalte
  columnNames  % 1 × m cellstr (stripws + lower)
  unit
  opts
end

methods
  function loader = loadHelper(d, varargin)
    columnNames = stripws(lower(get_option(varargin,'ColumnNames')));
    columns = get_option(varargin,'Columns',1:length(columnNames));
    assert(length(columnNames) == length(columns), ...
      'Length of ColumnNames and Columns differ');

    [columnNames, m] = unique(columnNames);

    loader.data        = d;            % <-- KEINE Kopie (copy-on-write)
    loader.colMap      = columns(m);   % nur die Index-Zuordnung
    loader.columnNames = columnNames;

    loader.unit = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});
    varargin  = delete_option(varargin,{'ColumnNames','Columns'},1);
    loader.opts = delete_option(varargin,{'radians','radiant','radiand'});
  end

  % --- interne Helfer -------------------------------------------------
  function idx = colIndex(loader,names)   % logische Indizes (in columnNames/colMap)
    names = stripws(lower(ensurecell(names)));
    [~,idx] = ismember(names,loader.columnNames);
  end

  function removeColumns(loader,idx)      % billig: nur Zuordnung kuerzen
    loader.colMap(idx)      = [];
    loader.columnNames(idx) = [];
  end
  % --------------------------------------------------------------------

  function out = hasColumns(loader,names)
    names = stripws(lower(ensurecell(names)));
    out = all(ismember(names,loader.columnNames));
  end

  function out = findColumn(loader,names)
    names = stripws(lower(ensurecell(names)));
    out = find(ismember(loader.columnNames,names),1);
  end

  function d = getColumnData(loader,colname)
    pos = loader.findColumn(colname);
    if isempty(pos)
      error(['No data of type ' colname ' found'])
    end
    d = loader.data(:, loader.colMap(pos));
    loader.removeColumns(pos);
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
    convNames = {'Euler','Bunge','Matthies','Roe','Kocks','Canova','Quaternion'};

    type = find(cellfun(@(c) loader.hasColumns(c),conventions),1,'first');
    assert(~isempty(type),'At least specify three Euler angles or four quaternion components should be specified!');

    idx  = loader.colIndex(conventions{type});
    phys = loader.colMap(idx);

    % kleiner Ausschnitt statt Schreibzugriff auf die grosse Matrix
    rotData = loader.data(:,phys);
    ind = abs(rotData(:,1)*loader.unit - 4*pi) < 1e-3;
    rotData(ind,:) = nan;

    if type <= 6
      flag = extract_option([convNames{type} loader.opts],convNames);
      if any(any(rotData>15))
        rotData = rotData * pi/180;
      end
      rot = rotation.byEuler(rotData, flag{:});
    else
      rot = rotation(quaternion(rotData));
    end

    if check_option(loader.opts,{'passive','passive rotation'})
      rot = inv(rot);
    end

    loader.removeColumns(idx);
  end

  function v = getVector3d(loader)
    conventions = {...
      {'x','y','z'};
      {'Polar' 'Azimuth'};
      {'Polar Angle' 'Azimuth Angle'};
      {'Colatitude','Longitude'};
      {'Colattitude','Longitude'};   % historisch
      {'Latitude','Longitude'};
      {'Lattitude','Longitude'}; };   % historisch
    conventions = cellfun(@(s) stripws(lower(s)),conventions,'UniformOutput',false);

    type = find(cellfun(@(c) loader.hasColumns(c),conventions),1,'first');
    assert(~isempty(type),'Columns for cartesian or spherical coordinates not specified!');

    idx  = loader.colIndex(conventions{type});
    phys = loader.colMap(idx);

    if ~check_option(loader.opts,'keepNaN')
      bad = any(isnan(loader.data(:,phys)),2);
      if any(bad)
        loader.data(bad,:) = [];   % einzige echte Kopie, nur falls Zeilen wegfallen
      end
    end

    if type == 1  % xyz
      v = vector3d(loader.data(:,phys));
    else          % spherical
      theta = loader.data(:,phys(1)) * loader.unit;
      rho   = loader.data(:,phys(2)) * loader.unit;
      if type >= 6, theta = pi/2 - theta; end
      v = vector3d.byPolar(theta,rho);
    end

    loader.removeColumns(idx);
  end

  function options = getOptions(loader,varargin)
    cols = ensurecell(get_option(varargin,'ignoreColumns',[]));
    for k = 1:length(cols)
      idx = loader.findColumn(cols{k});
      if ~isempty(idx), loader.removeColumns(idx); end
    end
    options = struct();
    for k = 1:numel(loader.columnNames)
      options.(loader.columnNames{k}) = loader.data(:, loader.colMap(k));
    end
  end

  function xyz = getPos(loader)
    if loader.hasColumns({'x','y','z'})
      idx = loader.colIndex({'x','y','z'});
      xyz = vector3d(loader.data(:, loader.colMap(idx)));
      loader.removeColumns(idx);
    elseif loader.hasColumns({'x','y'})
      ix = loader.colIndex('x');  iy = loader.colIndex('y');
      xyz = vector3d(loader.data(:, loader.colMap(ix)), loader.data(:, loader.colMap(iy)), 0);
      loader.removeColumns([ix iy]);
    else
      error('No columns with "x" and "y" coordinates found!')
    end
  end
end
end