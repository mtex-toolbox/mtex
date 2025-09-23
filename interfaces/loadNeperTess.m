function [dimension, V, F, ori, CS, varargout] = loadNeperTess(filepath)
% function for reading data from Neper tessellation files (.tess)
%
% Description
%
% readTessFile is a helping function used from the grain2d.load and
% grain3d.load method to read the data from the tessellation files that
% <neper.info/ neper> outputs
%
% Syntax
%   [dim, V, poly, rot, CS, I_GrainsFaces] = readTessFile('filepath/filename.tess')
%
% Input
%  fname    - file name
%
% Output
%  dim      - dimension of the tessellation (2 or 3)
%  V        - list of vertices(x,y,z)
%  F        - cell array with all faces
%  ori      - rotation (orientation)
%  CS       - @crystalSymmetry
%  I_GF     - incidence matrix grains - faces
%  cell_ids - ids of the cells according to initial 3d tessellation
%
% See also
% grain2d.load grain3d.load neper
%

fid = fopen(filepath, 'r');
assert(fid ~= -1,'file could not be opened')

assert(strtrim(fgetl(fid)) == "***tess",...
  'file has wrong structure. line 1 has to be "***tess"!');

% format is something like version
assert(strtrim(fgetl(fid)) == "**format",...
  'file has wrong structure. line 2 has to be " **format"! Be careful with blank characters.');
format = fgetl(fid); %#ok<NASGU>

%% **general
assert(strtrim(fgetl(fid)) == "**general",...
  'file has wrong structure. line 4 has to be " **general"! Be careful with blank characters.');
dimension = fscanf(fid, '%d' , 1);
type = fscanf(fid, '%s', 1); %#ok<NASGU>
fgetl(fid);                %eliminate the \n character

%% grain orientations -> **cell

assert(strtrim(fgetl(fid)) == "**cell",...
  'file has wrong structure. line 6 has to be " **cell"! Be careful with blank characters.');

numGrains = str2double(fgetl(fid)); %#ok<NASGU>

buffer=fgetl(fid);
while true
  switch strtrim(buffer)
    case "*id"
      cell_ids = fscanf(fid,'%u', inf);
      buffer = fgetl(fid);
    case "*crysym"
      buffer = fgetl(fid);
      while(~isHeader(buffer))
        CS = strtrim(buffer);
        buffer = fgetl(fid);
      end
    case "*mode"
      modes = fscanf(fid,'%u', inf);
      buffer = fgetl(fid);
    case {"*seed","*seed (id x y z weigth )"}
      % we do not need this
      seeds = fscanf(fid,'%u %f %f %f %f ', [5 inf]); %#ok<NASGU>
      buffer = fgetl(fid);
    case "*ori"
      buffer = fgetl(fid);
      quaternion_descriptor = split(buffer, ':');
      switch lower(strtrim(quaternion_descriptor{1}))
        case 'quaternion'
          abcd = fscanf(fid,'%f %f %f %f ',[4 inf]);
          ori = rotation(abcd);
        case 'rodrigues'
          vec = fscanf(fid,'%f %f %f ',[3 inf]);
          ori = rotation.byRodrigues(vec.');
        otherwise
          error('orientation in wrong format. currently only available for quaternion');
      end
        
      % convert to passive rotation if needed
      %if ~strcmpi(strtrim(quaternion_descriptor{2}),'active')
      %rot = inv(rot);
      %end

      buffer=fgetl(fid);
    case "**vertex"
      % this we will consider in the next section
      break
    otherwise
      error('Error while reading cell parameters failed. file has wrong structure, expression "%s" not known', buffer)
  end
end

%% load vertices -> **vertex
numV = str2double(fgetl(fid)); %#ok<NASGU>
V = fscanf(fid,'%u %f %f %f %d ',[5 inf])';
V = V(:,2:4);

%% load edges -> **edge
% we do not need the edges
skipEmptyLines(fid)
assert(strtrim(fgetl(fid)) == "**edge",' **edge" not found');

skipEmptyLines(fid)
numEdges = str2double(fgetl(fid));
skipEmptyLines(fid)

Lines = textscan(fid, '%[^\n]', numEdges, 'Delimiter', '\n');

%% load faces -> **face

skipEmptyLines(fid)
assert(strtrim(fgetl(fid)) == "**face", '" **face" not found');
skipEmptyLines(fid)
numAllFaces = str2double(fgetl(fid));

% Read the next 4*numAllFaces lines in one call
Lines = textscan(fid, '%[^\n]', 4*numAllFaces, 'Delimiter', '\n');
Lines = Lines{1};

% Keep only the header line of each 4-line face block
Lines = Lines(1:4:end);

% each line line is: faceId, numVertex, VId1, VId2, ....., VIdN
F = cell(numAllFaces,1);
for i = 1:numAllFaces  
  value = sscanf(Lines{i},'%d'); 
  F{i} = value([3:end,3]).';
end

%% load grains -> **polyhedron

if dimension == 3

  skipEmptyLines(fid)
  assert(strtrim(fgetl(fid)) == "**polyhedron",'" **polyhedron" not found')
  
  % next line contains number of polyhedrons/grains
  numGrains = str2double(fgetl(fid));
  
  % read all polyhedrons
  Lines = textscan(fid, '%[^\n]', numGrains, 'Delimiter', '\n');
  Lines = Lines{1};
  grains = cell(numGrains,1);
  for k = 1:numGrains, grains{k} = sscanf(Lines{k},'%d'); end
   
  % each line of contains
  % grainId numFaces FaceId1 FaceId2 FaceId2 ... FaceId1
  % we store these data in a grains x faces incidence matrix
  % with values +-1 indicting whether the face normal points out of the grain
  grainId = cellfun(@(x) x(1),grains);
  numFaces = cellfun(@(x) x(2),grains);
  faceId = cellfun(@(x) x(3:end).',grains,'UniformOutput',false);
  
  grainId = repelem(grainId,numFaces);
  faceId = [faceId{:}];
  I_GF = sparse(grainId, abs(faceId), sign(faceId), max(grainId),numAllFaces);
  
  varargout{1} = I_GF;
  
elseif (dimension == 2)
  varargout{1} = cell_ids;
end

fclose(fid);
end

function skipEmptyLines(fid)
% function to ignore/skip possible empty lines
i = ftell(fid);
skipEmptyLinesBuffer = fgetl(fid);
while (skipEmptyLinesBuffer == "")
  i = ftell(fid);
  skipEmptyLinesBuffer = fgetl(fid);
end
fseek(fid, i, "bof");

end

function returnvalue = isHeader(buffer)
% function to check if buffer is Header (=starts with *)
returnvalue = strncmp(strtrim(buffer), "*", 1);
end

%{
  variables:
      -filepath
        - string - file that was read
      -format
        - string
      -dimension
        - int - dimension of the tessellation
      -type
        - string
      -total_number_of_cells
        - int
      -total_number_of_cells
        - int
      -total_number_of_vertices
        - int
      -total_number_of_edges
        - int
      -total_number_of_faces
        - int
      -seeds
        - total_number_of_cells x 5 matrix (seed_id,seed_x,seed_y,seed_z,seed_weight) 
      -quaternion_descriptor
        - string (1x1 cell)
      -I_EF
        - obsolete: adjacency matrix edges - faces
      -E
      	- list of edges as indices to V
      -I_GrainsFaces
        - adjacency matrix grains - faces
      -cell_ids
        - vector, Ids of the cells acording to initial 3d tesselation
      -dim        - int, dimension of the tesselation (2 or 3)
      -V          - list of vertices(x,y,z)
      -poly       - cell arry with all faces
      -rot        - rotation (orientation)
      -crysym     - crysym, character string
  
%}
