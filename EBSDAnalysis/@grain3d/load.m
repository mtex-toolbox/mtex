function [grains] = load(filepath)
  % load tesselation data from neper files
 
  [V, poly, I_CF] = readTess3File(filepath);
  grains=grain3d(V,poly,I_CF);

end

function [V, poly, I_CellsFaces] = readTess3File(filepath)
  % function for reading data from nepers tesselation files (.tess)
  %
  % Description
  %
  % readTess3File is a helping function used from the grain3d.load method to
  % read the data from the tesselation files that
  % <neper.info/ neper> outputs (only 3 dimesional tesselations. For 2 
  % dimensional tesselations see readTessFile)
  %
  % Syntax
  %   [V, E, poly, I_CellsFaces] = readTess3File('filepath/filename.tess')
  %
  % Input
  %  filepath     - filepath
  %
  % Output
  %  V          - list of vertices(x,y,z)
  %  E          - list of edges as indices to V
  %  poly       - cell arry with all faces
  %  I_CF       - adjacency matrix cells - faces
  %
  % Example
  %
  %   
  %   [V, E, I_EF, I_CellsFaces] = readTess3File('allgrains.tess')
  %
  % See also
  % grain3d.load grain2d.load
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
      -crysym
        - string 
      -seeds
        - total_number_of_cells x 5 matrix (seed_id,seed_x,seed_y,seed_z,seed_weight) 
      -quaternion_descriptor
        - string (1x1 cell)
      -oriMatrix
        - matrix[total_number_of_cells,4] containing the quaternion values 
      -total_number_of_cells
        - int
      -total_number_of_vertices
        - int
      -total_number_of_edges
        - int
      -total_number_of_faces
        - int
      -I_EF
        - obsolet: adjecency matrix edges - faces
      -V
        - see output
      -E
      	- list of edges as indices to V
      -poly
        - cell arry with all faces
      -I_CellsFaces
        - adjecency matrix cells - faces
  
  %}
  
  %% open file
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
  if dimension~=3
    error 'for 2 dimensional tess files use readTessFile()'
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
      case "*crysym"
        disp ("reading  *crysym ...");
        buffer=fgetl(fid);
        while(~isHeader(buffer))
          crysym=strtrim(buffer);
          buffer=fgetl(fid);
        end
      case {"*seed","*seed (id x y z weigth )"}
        disp ("reading  *seed ...");
        seeds=fscanf(fid,'%u %f %f %f %f ', [5 inf]);
        seeds=seeds';
        buffer=fgetl(fid);
      case "*ori"
        disp ("reading  *ori ...");
        buffer=fgetl(fid);
        quaternion_descriptor=split(buffer, ':');
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
        disp("reading **vertex ...")
        break
      otherwise
        error('Error while reading cell parameters failed. file has wrong structure, expression "%s" not known', buffer)
    end
  end

  %% **vertex
  total_number_of_vertices=str2double(fgetl(fid));
  V=fscanf(fid,'%u %f %f %f %d ',[5 inf])';
  V=V(:,2:4);

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

  E=zeros(total_number_of_edges,2);
  for i=1:total_number_of_edges                  
    buffer=fgetl(fid);
    buffer=split(buffer);
    E(i,:)=str2double(buffer(3:4));
  end

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

  I_EF=zeros(total_number_of_edges,total_number_of_faces);  
  poly{total_number_of_faces,1}=[];

  % read in poly
  for i=1:total_number_of_faces

    buffer=fgetl(fid);
    buffer=split(buffer);
    for j=4:3+str2num(cell2mat(buffer(3)))
      poly{i}=[poly{i,1} str2double(buffer(j))];
    end
    poly{i}=[poly{i,1} str2double(buffer(4))];

    %buffer=...
      fgetl(fid);
    %{
    EF=split(buffer);
    sizeEF=str2double(EF(2));
    for j=3:sizeEF+2
      el=str2double(EF(j));
      I_EF(abs(el), i)=sign(el)*1;
    end
    %}

    fgetl(fid);
    fgetl(fid);
  end

  %% **polyhedron
  skipEmptyLines(fid)
  buffer=fgetl(fid);
  if (buffer~=" **polyhedron")
    error '" **polyhedron" not found'
  else
    disp("reading **polyhedron ...");
  end
  total_number_of_polyhedra=str2double(fgetl(fid));

  I_CellsFaces=zeros(total_number_of_polyhedra,total_number_of_faces);  

  for i=1:total_number_of_polyhedra
    buffer=fgetl(fid);
    CF=split(buffer);
    currentNumOfFaces=str2double(CF(3));
    for j=4:currentNumOfFaces+3
      el=str2double(CF(j));
      I_CellsFaces(i, abs(el))=sign(el)*1;
    end
  end
  %% close file
  fclose(fid);
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

end

%%
function returnvalue = isHeader(buffer)
  % function to check if buffer is Header (=starts with *)
  returnvalue=strncmp(strtrim(buffer), "*", 1);
end
