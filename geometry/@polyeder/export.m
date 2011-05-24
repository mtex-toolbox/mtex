function varargout = export(p, fname, color, ocupacy)
%EXPORT Summary of this function goes here
%
%% Syntax
% export(grains,'grains.ply',rgb) - export grains to Polygon File Format
%    (ply) / Stanford Triangle Format
%
% mesh = export(grains,'grains.mesh',rgb,ocupacy) - prepare polyeder for
%    conversion in idtf/u3d format
%
%% Example
%
% export individual grainboundaries
% 
% [~,boundary] = plotboundary(grains,'property','angle')
% model = export(boundary,'boundary.mesh',[0 1 0],0.6)
% [~,subboundary] = plotSubBoundary(grains)
% model2 = export(boundary,'subboundary.mesh',[1 0 0],0.8)
% 
% model.mesh = [model.mesh model2.mesh];
% save_idtf('boundary.idtf',model)
% idtf2u3d('boundary.idtf','boundary.u3d')
%
%% Options
%

if nargin < 3
  color = round(rand(numel(p),3)*255);
else
  if max(color(:)) <= 1
    color = color*255;
  end
  color = round(color);
  
  if size(color,1) ~= numel(p)
    color = repmat(color,numel(p),1);
  end
end

if nargin <4 
  ocupacy = 0.8;
end

p = polyeder(p);

[pname,fname,ext]= fileparts(fname);


Vertices = cell(size(p));
Faces = cell(size(p));
Colors = cell(size(p));

for k=1:numel(p)
  V = p(k).Vertices;
  F = p(k).Faces;
  C = repmat(color(k,:),size(V,1),1);
  
  reverse = p(k).FacetIds < 0;
  F(reverse,:) = F(reverse,end:-1:1);
  
  if size(F,2)>3
    F = [F(:,1:3);F(:,[3 4 1])];
  end
  
  Vertices{k} = V;
  Faces{k} = F;
  Colors{k} = C;
end


switch lower(ext)
  case '.ply'
    fid = fopen(fullfile(pname,[fname ext]),'w');
    offset = [0; cumsum(cellfun('size',Vertices(:),1))];
    for k=1:numel(Vertices)
      Faces{k} = Faces{k} + offset(k);
    end
    
    V = vertcat(Vertices{:});
    F = vertcat(Faces{:});
    C = vertcat(Colors{:});
    
    writePlyHeader(fid,size(V,1),size(F,1));
    writePlyVertices(fid,V,C);
    writePlyFaces(fid,F);
    fclose(fid);
  case {'.mesh','.idtf'}
    mesh = struct;
    
    for k=1:numel(Vertices)
      nfname = [fname num2str(k)];
      mesh(k).layername = nfname;
      mesh(k).resourcename = [nfname 'resource'];
      mesh(k).f = Faces{k};
      mesh(k).v = Vertices{k};
      mesh(k).colors = Colors{k};
      mesh(k).opacity = ocupacy;
    end   
    
    model.name = 'MODEL';
    model.mesh = mesh;
    % save_idtf('foobaa.idtf',model)
    varargout{1} = model;
end


function writePlyHeader(fid,nV,nF)

fprintf(fid,'ply\n');
fprintf(fid,'format ascii 1.0\n');
fprintf(fid,'element vertex %d\n',nV);
fprintf(fid,'property float x\n');
fprintf(fid,'property float y\n');
fprintf(fid,'property float z\n');
fprintf(fid,'property uchar red\n');
fprintf(fid,'property uchar green\n');
fprintf(fid,'property uchar blue\n');
fprintf(fid,'element face %d\n',nF);
fprintf(fid,'property list uchar int vertex_index\n');
fprintf(fid,'end_header\n');

function writePlyVertices(fid,V,C)

fprintf(fid,'%f %f %f %d %d %d\n',[V,C]');

function writePlyFaces(fid,F)

d = size(F,2);
n = size(F,2);

F = [repmat(d,size(F,1),1)+1 F];
format = [deblank(['%d ',repmat('%d ',1,n)]),'\n'];
fprintf(fid,format,F'-1);

