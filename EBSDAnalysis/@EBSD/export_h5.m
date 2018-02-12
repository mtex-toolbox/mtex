function export_h5(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
% Input
%  ebsd - @EBSD
%  fname - filename
%
% Options
%  BUNGE   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  DEGREE  - output in degree (default)
%  RADIANS - output in radians


if nargin > 2
  root = varargin{1};
else  
  root = ['/' inputname(1)];  
end

[p,f] = fileparts(fname);
fname = fullfile(p,[f '.h5']);

CSList = ebsd.CSList;
phaseMap = ebsd.phaseMap;

for k=1:numel(CSList)
  CS = CSList{k};
  
  cm = phaseMap(k);
  
  name = [root '/Phase/' num2str(cm) ];
  
  h5create(fname,name,1)
  h5write(fname,name,cm);
  
  if isa(CS,'symmetry')
    
    h5writeatt(fname,name,'Name',CS.pointGroup);
    h5writeatt(fname,name,'Mineral',CS.mineral);
    h5writeatt(fname,name,'Color',CS.color);
    h5writeatt(fname,name,'Laue',CS.LaueName);
    
    ax = norm(CS.axes);
    h5writeatt(fname,name,'a',ax(1));
    h5writeatt(fname,name,'b',ax(2));
    h5writeatt(fname,name,'c',ax(3));
    
    h5writeatt(fname,name,'alpha',CS.alpha);
    h5writeatt(fname,name,'beta',CS.beta);
    h5writeatt(fname,name,'gamma',CS.gamma);
    
    ali = CS.alignment;
    if numel(ali) >0
      ali(1:end-1) = strcat(ali(1:end-1),', ');
      ali = regexprep([ali{:}],',',', ');
      h5writeatt(fname,name,'Alignment',ali);
    end
    
  else
    
    h5writeatt(fname,name,'Name',CS);
    
  end
  
end


n = length(ebsd);

if n > 2^14
  chnk = 2^14;
else
  chnk = n;
end
opts =  {'Deflate',get_option(varargin,{'compression','Deflate'},9)};


[phi1,Phi,phi2] = Euler(ebsd.rotations,'ZXZ');

h5create(fname,[root '/Orientations'],[3 n],'Datatype','single','ChunkSize',[3 chnk],opts{:});
h5write(fname,[root '/Orientations'],double([phi1 Phi phi2]'));

h5writeatt(fname,[root '/Orientations'],'Parameterization','Euler');
h5writeatt(fname,[root '/Orientations'],'Convention','ZXZ');
h5writeatt(fname,[root '/Orientations'],'Unit','Radian');
h5writeatt(fname,[root '/Orientations'],'Mapping','Active');

h5create(fname,[root '/PhaseIndex'],[1 n],'Datatype','uint8','ChunkSize',[1 chnk],opts{:});
h5write(fname, [root '/PhaseIndex'],ebsd.phase(:).');

fn = fields(ebsd.prop);


if all(isfield(ebsd.prop,{'x','y','z'}))
  coords = [ebsd.prop.x,ebsd.prop.y,ebsd.prop.z];
elseif all(isfield(ebsd.prop,{'x','y'}))
  coords = [ebsd.prop.x,ebsd.prop.y];
end

if ~isempty(coords)
  h5create(fname,[root '/SpatialCoordinates'],[size(coords,2) n],'Datatype','single','ChunkSize',[size(coords,2) chnk],opts{:});
  h5write(fname,[root '/SpatialCoordinates'],double(coords'));
  
  u = ebsd.unitCell;
  if ~isempty(u)
    h5writeatt(fname,[root '/SpatialCoordinates'],'Unit','unknown')
    h5writeatt(fname,[root '/SpatialCoordinates'],'UnitCell',u)
  end
end

for k=1:numel(fn)
  
  p = ebsd.prop.(fn{k});
  
  if any(strcmp(fn{k},{'x','y','z'}))
    
    %     h5create(fname,['/EBSD/SpatialCoordinates/' fn{k}],n,opts{:});
    %     h5write(fname, ['/EBSD/SpatialCoordinates/' fn{k}],p);
    
  else
    if ~any(mod(p,1) ~= 0) % its an int
      
      if min(p) >= 0
        dtype = num2str(2^(sum(max(p) > 2.^(2.^(3:6))-1)+3),'uint%d');
      else
        dtype = num2str(2^(sum(max(p) > 2.^(2.^(3:6))-1)+3),'uint%d');
      end
      
    else
      dtype = 'single';
    end
    
    dim = min(size(p));
    h5create(fname,[root '/Properties/' fn{k}],[dim n],'Datatype',dtype,'ChunkSize',[dim chnk],opts{:});
    h5write(fname, [root '/Properties/' fn{k}],reshape(p',dim,[]));
    
  end
  
end


h5writeatt(fname,root,'DataType','EBSD');
h5writeatt(fname,root,'CreationTime',datestr(clock));




