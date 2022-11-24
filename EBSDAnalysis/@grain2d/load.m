function [grains] = load(filepath)
  % load tesselation data from neper files
  %
  % Description
  %
  % grain2d.load is a method to load the data from the tesselation files that
  % <neper.info/ neper> outputs (only 2 dimesional tesselations!)
  %
  % Syntax
  %   grains = grain2d.load('filepath/filename.tess')
  %
  % Input
  %  fname     - filename
  %
  % Output
  %  grain2d - @grain2d
  %
  % See also
  % readTessFile

  %filepath="2dslice.tess";

  %%

  [dimension,V,poly,oriMatrix,crysym] = readTessFile(filepath);

  if (dimension~=2)
    error 'format is not 2 - only two dimesional tesselations allowed'
  end

  CSList={'notIndexed',crystalSymmetry(crysym)};
  rot=rotation(quaternion(oriMatrix'));
  phaseList=2*ones(size(poly));

  grains = grain2d(V,poly,rot,CSList,phaseList);

  %% check for clockwise poly's

  isNeg = (grains.area<0);
  grains.poly(isNeg) = cellfun(@fliplr, grains.poly(isNeg), 'UniformOutput', false);

end

function [dimension,V, poly,oriMatrix,crysym] = readTessFile(filepath)
  % function for reading data from nepers tesselation files (.tess)
  %
  % Description
  %
  % readTessFile is a helping function used from the grain2d.load method to
  % read the data from the tesselation files that
  % <neper.info/ neper> outputs (only 2 dimesional tesselations!)
  %
  % Syntax
  %   [V,poly,oriMatrix,crysym] = readTessFile('filepath/filename.tess')
  %
  % Input
  %  fname     - filepath
  %
  % Output
  %  V - matrix[total_number_of_vertices,2] of vertices(x,y)
  %  poly - cell array of the polyhedrons, clockwise or against the clock
  %  oriMatrix - matrix[total_number_of_cells,4] containing the quaternion values
  %  crysym - crysym
  %
  % Example
  %
  %   
  %   [V,poly,oriMatrix,crysym] = readTessFile('fname')
  %
  % See also
  % grain2d.load
  %

  %{
  variables:
      -filepath
        - string - file that was read
      -format
        - string
      -dimension
        - int - dimension of the tesselation
      -type
        - string
      -total_number_of_cells
        - int
      -cell_ids
        - vector
      -crysym
        - see output, string 
      -seedsTable('seed_id', 'seed_x', 'seed_y', 'seed_z', 'seed_weight')
        - table 
      -quaternion_descriptor
        - string (1x1 cell)
      -oriMatrix
        - see output 
      -verticesTable('ver_id','ver_x', 'ver_y','ver_z','ver_state')

      -edgesTable('egde_id', 'vertex_1', 'vertex_2', 'edged_state')
  
      -total_number_of_cells
        - int
      -total_number_of_vertices
        - int
      -total_number_of_edges
        - int
      -total_number_of_faces
        - int
      -I_FD
        - incidence matrix edges - grains/face
      -V
        - see output
      -F
      	- list of edges as indices to V
      -poly
        - see output
  
  %}
  
  %%

  %open file
  fid=fopen(filepath, 'r');

  if (fid==-1)
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
  else
    disp("reading **format ...");
  end
  format = fscanf(fid, '%s', 1);       
  fgetl(fid);                %eliminate the \n character

  %% **general
  buffer = fgetl(fid);
  if (~(strcmp(buffer, ' **general')))
    error 'file has wrong structure. line 4 has to be " **general"! Be careful with blank characters.';
  else
    disp("reading **general ...");
  end
  dimension = fscanf(fid, '%d' , 1);
  if dimension~=2
    error 'only two dimensional tesselations supported'
  end
  type = fscanf(fid, '%s', 1);
  fgetl(fid);                %eliminate the \n character

  %% **cell
  buffer = fgetl(fid);
  if (~(strcmp(buffer, ' **cell')))
    error 'file has wrong structure. line 6 has to be " **cell"! Be careful with blank characters.';
  else
    disp("reading **cell ...");
  end
  total_number_of_cells = str2double(fgetl(fid));

  buffer=fgetl(fid);
  while (1)
    switch strtrim(buffer)
      case "*id"
        disp ("reading  *id ...")
          cell_ids=fscanf(fid,'%u', inf);
          buffer=fgetl(fid);
      case "*crysym"
        disp ("reading  *crysym ...");
        buffer=fgetl(fid);
        while(~isHeader(buffer))
          crysym=strtrim(buffer);
          buffer=fgetl(fid);
        end
      case {"*seed","*seed (id x y z weigth )"}
        disp ("reading  *seed ...");                    %output as table
        seedsTable=fscanf(fid,'%u %f %f %f %f ', [5 inf]);
        seedsTable=array2table(seedsTable');
        seedsTable.Properties.VariableNames(1:5)={'seed_id', 'seed_x', 'seed_y', 'seed_z', 'seed_weight'};
        buffer=fgetl(fid);
      case "*ori"
        disp ("reading  *ori ...");
        buffer=fgetl(fid);
        quaternion_descriptor=split(buffer, ':');
        if (strtrim(quaternion_descriptor(1))~="quaternion")
          error 'orientation in wrong format. currently only available for quaternion';
        end
        quaternion_descriptor=strtrim(quaternion_descriptor(2));
        oriMatrix=fscanf(fid,'%f %f %f %f ',[4 inf]);          %output as matrix
        oriMatrix=oriMatrix';
        buffer=fgetl(fid);
      case "**vertex"
        disp("reading **vertex ...")
        break
      otherwise
        error('Error while reading cell parameters failed. file has wrong structure, expression "%s" not known', buffer)
    end
  end

  %% **vertex
  total_number_of_vertices=str2double(fgetl(fid));
  verticesTable=fscanf(fid,'%u %f %f %f %d ',[5 inf]);
  verticesTable=array2table(verticesTable');          
  verticesTable.Properties.VariableNames(1:5)={'ver_id','ver_x', 'ver_y','ver_z','ver_state'};

  % rotate the 2dslice into xy-plane (z becomes zero)
  V=table2array(verticesTable(:,2:4));
  A=V(1,:);
  B=V(2,:);
  C=V(3,:);

  v1=B-A;
  v2=C-A;
  z=[0,0,1];

  n=cross(v1,v2);
  n=1/norm(n)*n;

  rot_angle=-asin(norm(cross(n,z))/(norm(n)*norm(z)));
  if rot_angle ~= 0 % rotate only if needed
  rot_axis=cross(n,z);
  rot_axis=1/norm(rot_axis)*rot_axis;

  R=rotation.byAxisAngle(vector3d(rot_axis),rot_angle);
  
  Vrot=zeros(total_number_of_vertices,3);
  for i=1:total_number_of_vertices
    buffer=R*vector3d(V(i,:));
    Vrot(i,:)=buffer.xyz;
  end
  V=Vrot-[0,0,Vrot(1,3)];
  end

  %set Z to 0 if slice is from somewhere above/below but not rotated
  if length(unique(V(:,3))) == 1
        V(:,3) = 0;
  end

  for i=1:length(V)
    if abs(V(i,3)) > 1e-9
      error('Error: vertices not in plane')
    end
  end
  V=V(:,1:2);

  clearvars A B C i n z R rot_angle rot_axis Vrot v1 v2

  %% **edge
  skipEmptyLines(fid)
  buffer=fgetl(fid);
  if (strtrim(buffer)~="**edge")
    error ' **edge" not found'
  else
    disp("reading **edge ...");
  end
  skipEmptyLines(fid)
  total_number_of_edges=str2double(fgetl(fid));
  skipEmptyLines(fid)
  % reading in edges
  varTypes={'uint32', 'uint32', 'uint32', 'int32'};
  varNames={'egde_id', 'vertex_1', 'vertex_2', 'edged_state'};
  edgesTable=table('Size', [0 4], 'VariableTypes', varTypes , 'VariableNames',varNames);
  for i=0:total_number_of_edges-1                   %Hier Kanten einlesen Zeilenweise zur Tabelle hinzufüg
    buffer=textscan(fid,'%u %u %u %d', 1);
    edgesTable=[edgesTable;buffer];
    %fgetl(fid);
  end

  F=table2array(edgesTable(:, 2:3));
  clearvars varNames varTypes
  %% **face
  skipEmptyLines(fid)
  buffer=fgetl(fid);
  if (buffer~=" **face")
    error '" **face" not found'
  else
    disp("reading **face ...");
  end
  skipEmptyLines(fid)
  total_number_of_faces=str2double(fgetl(fid));

  I_FD=zeros(total_number_of_edges,total_number_of_faces);  
  clear poly
  poly{total_number_of_cells,1}=[];

  % read in I_FD and poly
  for i=1:total_number_of_faces

    buffer=fgetl(fid);
    buffer=split(buffer);

    for j=4:3+str2num(cell2mat(buffer(3)))
      poly{i}=[poly{i,1} str2double(buffer(j))];
    end
    %A(length(A))
    poly{i}=[poly{i,1} str2double(buffer(4))];

    buffer=fgetl(fid);
    FD=split(buffer);
    sizeFD=str2double(FD(2));
    for j=3:sizeFD+2
      I_FD(abs(str2double(FD(j))), i)=1;
    end

    fgetl(fid);
    fgetl(fid);
  end

  clearvars i j sizeFD FD
  %% close file
  fclose(fid);
  clearvars fid buffer
end 

%%
function skipEmptyLines(fid)
  % function to ignore/skip possible empty lines
  i=ftell(fid);
  skipEmptyLinesBuffer=fgetl(fid);
  while (skipEmptyLinesBuffer=="")
    i=ftell(fid);
    skipEmptyLinesBuffer=fgetl(fid);
  end
  fseek(fid, i, "bof");

  clearvars i skipEmptyLinesBuffer
end

%%
function returnvalue = isHeader(buffer)
  % function to check if buffer is Header (=starts with *)
  returnvalue=strncmp(strtrim(buffer), "*", 1);
end
