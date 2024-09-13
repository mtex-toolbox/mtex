function [dimension, V, poly, rot, CS, varargout] = loadNeperTess(filepath)
  % function for reading data from nepers tessellation files (.tess)
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
  %  fname     - filepath
  %
  % Output
  %  dim        - dimension of the tessellation (2 or 3)
  %  V          - list of vertices(x,y,z)
  %  poly       - cell array with all faces
  %  rot        - rotation (orientation)
  %  CS         - @crystlSymmetry
  %  I_GrainsFaces  - adjacency matrix grains - faces
  %  cell_ids   - ids of the cells according to initial 3d tessellation
    %
  % See also
  % grain2d.load grain3d.load neperInstance
  %

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
  
  %% open file
  fid = fopen(filepath, 'r');

  if (fid == -1)
    error 'file could not be opened'
  end

  %% ***tess
  % read file line for line
  buffer = fgetl(fid);
  if (~(strcmp(buffer, '***tess')))
    error 'file has wrong structure. line 1 has to be "***tess"!';
  end

  %% **format
  buffer = fgetl(fid);
  if (~(strcmp(buffer, ' **format')))
    error 'file has wrong structure. line 2 has to be " **format"! Be careful with blank characters.';
  end
  format = fscanf(fid, '%s', 1);       
  fgetl(fid);                %eliminate the \n character

  %% **general
  buffer = fgetl(fid);
  if (~(strcmp(buffer, ' **general')))
    error 'file has wrong structure. line 4 has to be " **general"! Be careful with blank characters.';
  end
  dimension = fscanf(fid, '%d' , 1);
  type = fscanf(fid, '%s', 1);
  fgetl(fid);                %eliminate the \n character

  %% **cell
  buffer = fgetl(fid);
  if (~(strcmp(buffer, ' **cell')))
    error 'file has wrong structure. line 6 has to be " **cell"! Be careful with blank characters.';
  end
  total_number_of_cells = str2double(fgetl(fid));

  buffer=fgetl(fid);
  while (1)
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
      case {"*seed","*seed (id x y z weigth )"}
        seeds = fscanf(fid,'%u %f %f %f %f ', [5 inf]);
        seeds = seeds';
        buffer = fgetl(fid);
      case "*ori"
        buffer = fgetl(fid);
        quaternion_descriptor = split(buffer, ':');
        switch lower(strtrim(quaternion_descriptor{1}))
          case 'quaternion'
            eulerAngles = fscanf(fid,'%f %f %f %f ',[4 inf]);
            rot = rotation(quaternion(eulerAngles));
          case 'rodrigues'
            vec = fscanf(fid,'%f %f %f ',[3 inf]);
            rot = rotation.byRodrigues(vec.');
          otherwise
            error('orientation in wrong format. currently only available for quaternion');
        end
        
        % convert to passive rotation if needed
        %if ~strcmpi(strtrim(quaternion_descriptor{2}),'active')
        %rot = inv(rot);
        %end

        buffer=fgetl(fid);
      case "**vertex"
        break
      otherwise
        error('Error while reading cell parameters failed. file has wrong structure, expression "%s" not known', buffer)
    end
  end

  %% **vertex
  total_number_of_vertices = str2double(fgetl(fid));
  V = fscanf(fid,'%u %f %f %f %d ',[5 inf])';
  V = V(:,2:4);

  %% **edge
  skipEmptyLines(fid)
  buffer = fgetl(fid);
  if (strtrim(buffer) ~= "**edge")
    error ' **edge" not found'
  end
  skipEmptyLines(fid)
  total_number_of_edges = str2double(fgetl(fid));
  skipEmptyLines(fid)

  E = zeros(total_number_of_edges,2);
  for i = 1:total_number_of_edges                  
    buffer = fgetl(fid);
    buffer = split(buffer);
    E(i,:) = str2double(buffer(3:4));
  end

  %% **face
  skipEmptyLines(fid)
  buffer = fgetl(fid);
  if (buffer ~= " **face")
    error '" **face" not found'
  end
  skipEmptyLines(fid)
  total_number_of_faces = str2double(fgetl(fid));

  %I_EF = zeros(total_number_of_edges,total_number_of_faces);  
  poly{total_number_of_faces,1} = [];

  % read in poly
  for i = 1:total_number_of_faces

    buffer = fgetl(fid);
    buffer = split(buffer);

    for j = 4:3+str2num(cell2mat(buffer(3)))
      poly{i} = [poly{i,1} str2double(buffer(j))];
    end
    poly{i} = [poly{i,1} str2double(buffer(4))];

    %buffer = ...
      fgetl(fid);
    %{
    EF = split(buffer);
    sizeEF = str2double(EF(2));
    for j = 3:sizeEF+2
      el = str2double(EF(j));
      I_EF(abs(el), i) = sign(el)*1;
    end
    %}

    fgetl(fid);
    fgetl(fid);
  end

  %% **polyhedron

  if (dimension == 3)

  skipEmptyLines(fid)
  buffer = fgetl(fid);

  if (buffer ~= " **polyhedron")
    error '" **polyhedron" not found'
  else
    total_number_of_polyhedra = str2double(fgetl(fid));

    I_GrainsFaces = zeros(total_number_of_polyhedra,total_number_of_faces);  
  
    for i = 1:total_number_of_polyhedra
      buffer = fgetl(fid);
      CF = split(buffer);
      currentNumOfFaces = str2double(CF(3));
      for j = 4:currentNumOfFaces+3
        el = str2double(CF(j));
        I_GrainsFaces(i, abs(el)) = sign(el)*1;
      end
    end
    varargout{1} = I_GrainsFaces;
  end
  elseif (dimension == 2)
    varargout{1} = cell_ids;
  end
  

  %% close file
  fclose(fid);
end 

%%
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

%%
function returnvalue = isHeader(buffer)
  % function to check if buffer is Header (=starts with *)
  returnvalue = strncmp(strtrim(buffer), "*", 1);
end
