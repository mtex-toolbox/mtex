function saveGrainSet_hdf5(grains, fname)
% Save GrainSet object to HDF5 format
%
%% Input
% ebsd    - @GrainSet
% fname   - output filepath
%

%% Grain2d check
if ~isa(grains, 'Grain2d')
  error('MTEX:ValueError',...
        'Only Grain2d is currently implemented.');
end

%% Extract structure
g = struct(struct(grains).GrainSet);

%% Save EBSD
saveEBSD_hdf5(g.EBSD, fname);

%% Save matrices
saveSparse(fname, '/grains/a_d', g.A_D);
saveSparse(fname, '/grains/i_dg', g.I_DG);
saveSparse(fname, '/grains/a_g', g.A_G);
saveSparse(fname, '/grains/i_fdext', g.I_FDext);
saveSparse(fname, '/grains/i_fdsub', g.I_FDsub);
saveSparse(fname, '/grains/f', g.F);
saveSparse(fname, '/grains/v', g.V);

%% Save mean rotations
meanrotations = g.meanRotation;

location = '/grains/meanrotation/a';
as = get(meanrotations, 'a');
h5create(fname, location, size(as));
h5write(fname, location, as);

location = '/grains/meanrotation/b';
bs = get(meanrotations, 'b');
h5create(fname, location, size(bs));
h5write(fname, location, bs);

location = '/grains/meanrotation/c';
cs = get(meanrotations, 'c');
h5create(fname, location, size(cs));
h5write(fname, location, cs);

location = '/grains/meanrotation/d';
ds = get(meanrotations, 'd');
h5create(fname, location, size(ds));
h5write(fname, location, ds);

%% Save phases
location = '/grains/phase';
phases = g.phase;
h5create(fname, location, size(phases));
h5write(fname, location, phases);

%% Save options
fields = fieldnames(g.options);
for i = 1:numel(fields)
    name = fields{i};
    if strcmp(name, 'boundaryEdgeOrder')
      continue
    end
    data = g.options.(name);
    
    location = ['/grains/options/', name];
    h5create(fname, location, size(data));
    h5write(fname, location, data);
end

%% Save comment
location = '/grains';
comment = g.comment;
h5writeatt(fname, location, 'comment', comment);

end

function saveSparse(fname, location, s) 
  [i, j, v] = find(s);
  h5create(fname, [location '/i'], size(i));
  h5write(fname, [location '/i'], i);
  h5create(fname, [location '/j'], size(j));
  h5write(fname, [location '/j'], j);
  h5create(fname, [location '/v'], size(v));
  h5write(fname, [location '/v'], double(v));
  clear i j v;
end

