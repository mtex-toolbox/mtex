function ebsd = loadEBSD_xnovo(fname,varargin)
% load Xnovo GrainMapper3D Result File (HDF)
%
% Input
%  fname - file name
%
% Output
%  ebsd    - @EBSD
%
% Flags
%  check         - internal

ebsd = EBSD;


map = get_option(varargin,'map','/LabDCT/','char');
try
    h5info(fname,[map '/Data']);
catch
    interfaceError(fname);
end

if check_option(varargin,'check')
    return
end

CSList = loadSymmetry(fname,varargin{:});

getData = @(dataset) double(h5read(fname,dataset));

datagroup = [map '/Data'];
datainfo = h5info(fname,datagroup);
datasets = {datainfo.Datasets.Name};

hasData = @(name) any(strcmp(name,datasets));

% read phase id
if hasData('PhaseId')
    msk = getData([datagroup '/PhaseId']);
else
    interfaceError(fname)
end

% read orientation data
q = quaternion;
if hasData('Rodrigues')
    rod = getData([datagroup '/Rodrigues']);
    q = squeeze(rotation.byRodrigues(vector3d(rod(1,:,:,:),rod(2,:,:,:),rod(3,:,:,:))));
elseif hasData('Quaternion')
    q = getData([datagroup '/Quaternion']);
    q = squeeze(rotation(q(1,:,:,:),q(2,:,:,:),q(3,:,:,:),q(4,:,:,:)));
elseif hasData('EulerZXZ')
    zxz = getData([datagroup '/EulerZXZ']);
    q = squeeze(rotation.byEuler(zxz(1,:,:,:),zxz(2,:,:,:),zxz(3,:,:,:),'ZXZ'));
elseif hasData('EulerZYZ')
    zyz = getData([datagroup '/EulerZYZ']);
    q = squeeze(rotation.byEuler(zyz(1,:,:,:),zyz(2,:,:,:),zyz(3,:,:,:),'ZYZ'));
else
    interfaceError(fname)
end

q(~isfinite(q.a) | ~isfinite(q.b)  | ~isfinite(q.c)  | ~isfinite(q.d)) = quaternion.id;


opt = struct();

if hasData('Completeness')
    cmp = getData([datagroup '/Completeness']);
    opt.Completeness = cmp(:);
end

if hasData('GrainId')
    gid = getData([datagroup '/GrainId']);
    opt.GrainId = gid(:);
end

center = getData([map '/Center']);       % or use h5group2struct(fname,h5info(fname,map));
voxsiz = getData([map '/Spacing']);
% vshift = getData([map '/VirtualShift']); %only relevant to convert back to original motor position (e.g. to register multiple datasets)

unitCell = @(dX)  [ ...
    -dX(1)/2   -dX(2)/2
    -dX(1)/2    dX(2)/2
    dX(1)/2    dX(2)/2
    dX(1)/2   -dX(2)/2
    -dX(1)/2   -dX(3)/2
    dX(1)/2   -dX(3)/2
    dX(1)/2    dX(3)/2
    -dX(1)/2    dX(3)/2
    -dX(2)/2   -dX(3)/2
    -dX(2)/2    dX(3)/2
    dX(2)/2    dX(3)/2
    dX(2)/2   -dX(3)/2];

numvox = size(msk);
dpos = @(ndx) (0:numvox(ndx)-1)*voxsiz(ndx) - (numvox(ndx)-1)*voxsiz(ndx)/2 + center(ndx);
[x,y,z] = ndgrid(dpos(1),dpos(2),dpos(3));

ebsd = EBSD3(vector3d(x(:),y(:),z(:)),q(:),double(msk(:)),CSList,opt);
ebsd.scanUnit = 'mm';

end


function cs = loadSymmetry(fname,varargin)

try
    if check_option(varargin,'CS','crystalSymmetry')
        cs = {'Not Indexed',get_option(varargin,'CS')};
    else
        h5phase = h5info(fname,'/PhaseInfo');
        group_info = h5phase.Groups;
        cs = cell(length(group_info)+1,0);
        cs{1} = 'Not Indexed';

        for i=1:length(group_info)
            phase_prefix = group_info(i).Name;

            sp = double(h5read(fname,[phase_prefix '/SpaceGroup']));
            uc = double(h5read(fname,[phase_prefix '/UnitCell']));
            info = {'x||a','z||c*'};

            if ~check_option(varargin,'nocolor')
                try
                    color = typecast(h5read(fname,[phase_prefix '/Color']),'uint8');
                    color = double(color(1:3))/255.0;
                    info = [info, {'color',color}];
                catch

                end
            end

            try
                name = cell2mat(h5read(fname,[phase_prefix '/Name']));
                info = [info, {'Mineral',name}];
            catch
                info = [info, {'Mineral',['Phase' num2str(i)]}];
            end

            try
                sym = h5read(fname,[phase_prefix '/UniversalHermannMauguin']);
                sym = sym{1};

                s = regexp(sym,'\(.+\)'); % some special settings
                if ~isempty(s)
                    sym = strip(sym(1:s(1)-1));
                end

                s = regexp(sym,':'); % some space grpups have alternative setting
                if ~isempty(s)
                    sym = strip(sym(1:s(1)-1));
                end

                try
                    cs{i+1} = Laue(crystalSymmetry(sym,uc(1:3),uc(4:6)*degree,info{:}));
                catch
                    s = regexprep(sym,' ','');
                    cs{i+1} = Laue(crystalSymmetry(s,uc(1:3),uc(4:6)*degree,info{:}));
                end
            catch
                cs{i+1} = Laue(crystalSymmetry('SpaceId',sp,uc(1:3),uc(4:6)*degree,info{:}));
            end

        end
    end
catch ex
    throw(MException('mtex:noPhaseInfo','Failed to import Phase Information'))
end

end


