%% The Class Miller
%
%% Abstract
% Miller indece
%
%% Contents
%
%% Description
%
% The class Miller is used in MTEX to work with Miller indece. Usualy they
% consist of three or four values h, l, k (,m) and a 
% [[symmetry_index.html,crystall symmetry]]. Essentially all operations
% defined for the [[vector3d_index.html,vector3d]] class are also available
% for Miller indece. Furthermore, You can ask for all crystallographically
% equivalent crystal directions to one Miller indece.
%
%% Definition
%
% Miller indice are definded by three coordinates h, k, l 
% (four in the case of trigonal or hecagonal crystal symmetry) and by the
% corresponding symmetry class. It is also possible to convert a vector3d
% object into a Miller indice.

cs = symmetry('trigonal');
m = Miller(1,0,-1,1,cs)
m = vec2Miller(zvector,cs)

%% Calculations
%
% Basic calculations on Miller indece includes aplying a certain
% orientation to obtain the corresponding specimen directions or applying a
% [[symmetry_index.html,crystal symmetry class]] to obtain all
% crystallographically equivalent specimen directions. Other methods to
% calculate or check for crystallographically equivalent Miller indece are
% [[Miller_symmetrise.html,symmetrise]] and [[Miller_eq.html,eq]]. In order
% to calculate the angle between two Miller indece use [[Miller_angle.html,angle]]

euler2quat(0,0,45*degree) * m; % applying a orientation
cs * m;                        % applying a symmetry class
symmetrise(m);                     % all equivalent directions 
eq(Miller(1,0,-1,0,cs),Miller(0,1,-1,0,cs)); % check for equivalents
angle(Miller(1,0,-1,0,cs),Miller(0,1,-1,0,cs)); % angle between both directions


%% Plotting Miller indece
%
% Miller indece are plotted as spherical projections. The specific
% projection as well as wheter to plot all equivalent directions can be
% specified by options.

plot(Miller(2,1,-3,1,cs),'all','labeled')   % plot Miller indece
