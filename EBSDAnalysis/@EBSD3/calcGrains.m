function varargout = calcGrains(ebsd,varargin) %#ok<STOUT,INUSD>
% grain reconstruction needs the voxels on a grid, see EBSD3square/calcGrains

error('calcGrains needs 3d EBSD data on a regular grid, i.e., an EBSD3square.')
