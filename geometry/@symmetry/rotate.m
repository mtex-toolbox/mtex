function Sv = rotate(S,v)
% symmetry * vektor3d
%
%% Input
%  S - @symmetry
%  v - @vector3d
%
%% Output
%  Sv - symmetricaly equivalent vectors


if isa(v,'vector3d')
    Sv = reshape(S.quat,[],1) * reshape(v,1,[]);
else
    error('wrong datatype')
end
