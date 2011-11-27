function gr = GrainSet(grainStruct,ebsd)


if nargin == 0
  grainStruct.comment = '';
  grainStruct.A_D     = sparse(0,0);
  grainStruct.I_DG    = sparse(0,0);
  grainStruct.A_G     = sparse(0,0);
  grainStruct.meanRotation ...
                      = rotation;
  grainStruct.phase   = [];
  grainStruct.I_FDext = sparse(0,0);
  grainStruct.I_FDsub = sparse(0,0);
  grainStruct.F       = sparse(0,0);
  grainStruct.V       = sparse(0,0);
  grainStruct.options = struct;
  ebsd = EBSD;
end

gr = class(grainStruct,'GrainSet',ebsd);