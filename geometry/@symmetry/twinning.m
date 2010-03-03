function sym = twinning(sym,law,fold) 
% adds twinning elements to point-group
%
%% Input
%  sym   - @symmetry
%  law   - alias or fold-axis @vector3d / @Miller
%  fold  - times of fold (optional)
%
%% Output
%  sym   - @symmetry
%
%% Supported Twinning
%  Laue  Alias         Law
%  2/m   manebach       {001}
%        carlsbad       [001]
%        braveno        {021}
%        staurolite1    {031}
%        staurolite2    {231}
%  mmm   cyclical       {110}
%  -3m   dauphine       [0001]
%        brazil         {11-10}
%        japanese       {11-22}
%        calcite1       {0001}
%        calcite2       {01-12}
%  m-3m  spinel         {-1-11}
%        perpendicular  3/[111]
%        ironcross      4/[001] 3/[111]
%


if isa(law,'char')
  law = lower(law);
  switch sym.laue
    case '-1'
      switch law
        case 'albite'
          axis = Miller(0,1,0,sym);
        case 'pericline'
          axis = vector3d(0,1,0);
      end
    case '2/m'
      switch law
        case 'manebach'
          axis = Miller(0,0,1,sym);
        case 'carlsbad'
          axis = vector3d(0,0,1);
        case 'braveno'
          axis = Miller(0,2,1,sym);
        case 'staurolite1'
          axis = Miller(0,3,1,sym);
        case 'staurolite2'
          axis = Miller(2,3,1,sym);
        case 'swallowtail'
          axis = Miller(1,0,0,sym);
      end
    case 'mmm'
      switch law
        case 'cyclical'
          axis = Miller(1,1,0,sym);       
      end          
    case '-3m'
      switch law
        case 'dauphine'
          axis = zvector;
        case 'brazil'
          axis = Miller(1,1,0,sym);
        case 'japanese'
          axis = Miller(1,1,2,sym);
        case 'calcite1'
          axis = Miller(0,0,1,sym);
        case 'calcite2'
          axis = Miller(0,1,2,sym);
      end 
    case 'm-3m'
      switch law
        case 'spinel'
          axis = Miller(-1,-1,1,sym);
        case 'perpendicular'
          sym = twinning(sym,vector3d(1,1,1),3);
          sym.mineral = [law sym.mineral];
          return
        case 'ironcross'
          sym = twinning(sym,vector3d([0 1],[0 1],[1 1]),[4 3]);
          sym.mineral = [law sym.mineral];
          return
      end
  end
  
  if ~exist('axis','var')
    help twinning
    error('twinning law "%s" not found',law);
  end
elseif isa(law,'Miller')
  axis = set(law,'CS',sym);
  law = '';
else
  axis = law;
  law = '';
end

if nargin < 3
  fold = 2;
end

maxis = vector3d(axis);

rot = sym.rotation;
for k=1:length(maxis)
  rot = reshape(rot,[],1).' * Axis(maxis(k),fold(k));
end

sym.rotation = rotation( reshape(rot,[],1) );
sym.mineral = [law ' twinning by ' char(axis) ];


