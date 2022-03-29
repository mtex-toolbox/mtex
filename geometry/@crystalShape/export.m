function export(cS,fname,varargin)
% Export crystal shape to 3D object
% overloads export
% Input
%  cS - @crystalShape
%  fname - output filename
% Output
%  3-d visualization file (e.g. '.stl', '.wrl','.ply')

% 3-d file structures available at: https://docs.fileformat.com/3d/

% Check extension
[~,~,ext] = fileparts(fname);
% Mineral name
solidName=cS.CS.mineral;
% Vector ids of each face
cSF=cS.F;
% Vertices coordinates
cSV=cS.V;

% Open output file
fileID = fopen(fname,'w');

switch lower(ext)
    case '.stl'
        
        % For every crystal facet
        for ii=1:size(cSF,1)
            % this facet
            f=cSF(ii,:);
            % Its vertices
            v=cSV(f(~isnan(f)));
            
            % check if the face is already a triangle
            if length(unique(v))==3
                % get connectivity list and vertex (points)
                cL=[1:4];
                P=v.xyz;         
                %   face normal
                F = cross(v(1)-v(2),v(2)-v(3))/norm(cross(v(1)-v(2),v(2)-v(3)));
                F=F.xyz;
            else
                % Create tetrahedra filling this face
                DT = delaunayTriangulation(v.x(1:end-1),v.y(1:end-1),v.z(1:end-1));  
                % get triangles filling tethraedra 
                [T,Xb] = freeBoundary(DT);
                TR = triangulation(T,Xb);
                % get connectivity list and vertex (points)
                cL=TR.ConnectivityList;
                P=TR.Points;
                % get normal to each triangle
                F = faceNormal(TR);
            end
            % For every triangle
            for jj=1:size(cL,1)
                fprintf(fileID,'facet normal %1.6e %1.6e %1.6e\n',[F(jj,:)]);
                fprintf(fileID,'\touter loop\n');
                % coordinates of each vertex of the triangle
                for kk=1:3
                    fprintf(fileID,'\t\tvertex %1.6e %1.6e %1.6e\n',[P(cL(jj,kk),:)]);
                end
                fprintf(fileID,'\tendloop\n');
                fprintf(fileID,'endfacet\n');
            end
        
            fprintf(fileID,'\tendloop\n');
            fprintf(fileID,'endfacet\n');
        end
        fprintf(fileID,'endsolid %s',solidName);
        fprintf('\nExported %s file as: %s.\n',ext,fname)
    
    case {'.ply'}
      
        fprintf(fileID,'ply\n');
        fprintf(fileID,'format ascii 1.0\n');
        fprintf(fileID,'comment %s\n',cS.CS.mineral); % add comment with mineral name
        fprintf(fileID,'element vertex %i\n',size(cSV,1)); %number of vertex
        fprintf(fileID,'property float x\n');
        fprintf(fileID,'property float y\n');
        fprintf(fileID,'property float z\n');
        fprintf(fileID,'element face %i\n',size(cSF,1)); % number of faces
        fprintf(fileID,'property list uchar int vertex_index\n');
        fprintf(fileID,'end_header\n');

        %print vertices
        fprintf(fileID,'%f %f %f\n',cSV.xyz');

        %print vertices ids
        for jj=1:size(cSF,1)
            % this facet
            f=cSF(jj,:);
            % Its vertices ids
            v=f(~isnan(f)); % remove nan column
            v=v(1:end-1); % remove repeated column
            v=[length(v), v-1]; % add number of vertices to the first element, subtract 1 (.ply starts with 0).
            str=strtrim(repmat('%i ',[1,length(v)]));
            fprintf(fileID,[str,'\n'], v);
        end
        fprintf('\nExported %s file as: %s.\n',ext,fname)
        
    case {'.wrl','.vrml'}

        % print headers
        fprintf(fileID,'#VRML V2.0 utf8\n\n');
        fprintf(fileID,'Shape{\n');
        fprintf(fileID,'\tgeometry IndexedFaceSet {\n');
        fprintf(fileID,'\t\tcoord Coordinate {\npoint [\n');

        %print vertices
        fprintf(fileID,'%6.6f  %6.6f  %6.6f\n',cSV.xyz');
       
        fprintf(fileID,']}\ncoordIndex [\n');

        %print vertices ids
        for jj=1:size(cSF,1)
            % this facet
            f=cSF(jj,:);
            % Its vertices ids
            v=f(~isnan(f));
            v=v-1; % Coordinates start with 0 (instead of 1)
            str=strtrim(repmat('%i ',[1,length(v)+1])); % +1 to account for final '-1'
            fprintf(fileID,[str,'\n'], [v,-1]);% -1 indicates that the face ends
        end

        fprintf(fileID,']\nsolid TRUE ccw FALSE }}');


        fprintf('\nExported %s file as: %s.\n',ext,fname)
    otherwise
        error('Export of crystal shape as %s file is not yet implemented.',ext)
end
fclose(fileID);