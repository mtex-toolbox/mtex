%% Test for calcKAM2

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {symmetry('2/m', [9.541 17.74 5.295], [90,103.67,90]*degree, 'X||a*', 'Y||b*', 'Z||c', 'mineral', 'p1')};

% specimen symmetry
SS = symmetry('-1');

% plotting convention
plotx2east

%% Specify File Names

% path to files
pname = [getpref('mtex','mtexPath') '/data/EBSD/'];

% which files to be imported
fname = {...
% [pname 'testdata_sqr.ctf'], ...
[pname 'testdata_hex.ctf'], ...
};


%% Import the Data

% create an EBSD variable containing the data
ebsd = loadEBSD(fname,CS,SS,'interface','ctf' ...
  );


%% Visualize the Data

plot(ebsd, 'property', 'phase')


%% Detect grains

%segmentation angle
segAngle = 10*degree;

grains = calcGrains(ebsd,'angle',segAngle);

%% Visualize the grains

% plot(grains,'property', [1:numel(grains)]');
plot(grains,'property','phase')

%% Split grains

xs = get(grains, 'x');
ys = get(grains, 'y');

%% Readjust indexes of A_D to the restrained set of voronois included 
% in the given grain set

A_D = get(grains, 'A_D');
b = find(any(get(grains, 'I_DG'), 2));
A_D = A_D(b,b);

% Select only voronois inside the grains
n = size(A_D,1);
I_FD = get(grains, 'I_FDext') | get(grains, 'I_FDsub');
[d,~] = find(I_FD(sum(I_FD,2) == 2, any(get(grains, 'I_DG'),2))');
Dl = d(1:2:end);
Dr = d(2:2:end);
A_D = A_D - sparse(Dl,Dr,1,n,n);
A_D = A_D | A_D';

A_D = double(A_D);

%% Define which pixel to look at

id = 115;
% id = 90;

%% Find first neighbour

% A_D1 = nadjacent(A_D,1);
A_D1 = nadjacent(A_D,1) - nadjacent(A_D,0); % Last term optional

%% Test first neighbour

[r c] = find(A_D1 | A_D1');

figure;
hold on;
for i = 1:size(r)
  if r(i) == id
    plot(xs(r(i)), ys(r(i)), 's', xs(c(i)), ys(c(i)), 's', 'MarkerSize', 10);
    text(xs(r(i)),ys(r(i)),int2str(r(i)));
    text(xs(c(i)),ys(c(i)),int2str(c(i)));
  end
end

%% Find second neighbour

% A_D2 = nadjacent(A_D,2);
A_D2 = nadjacent(A_D,2) - nadjacent(A_D,1);

%% Test second neighbour

[r c] = find(A_D2 | A_D2');

for i = 1:size(r)
  if r(i) == id
    plot(xs(r(i)), ys(r(i)), '^', xs(c(i)), ys(c(i)), '^', 'MarkerSize', 20);
    text(xs(r(i)),ys(r(i)),int2str(r(i)));
    text(xs(c(i)),ys(c(i)),int2str(c(i)));
  end
end

%% Find third neighbour

% A_D3 = nadjacent(A_D,3);
A_D3 = nadjacent(A_D,3) - nadjacent(A_D,2);

%% Test third neighbour

[r c] = find(A_D3 | A_D3');

for i = 1:size(r)
  if r(i) == id
    plot(xs(r(i)), ys(r(i)), 'o', xs(c(i)), ys(c(i)), 'o', 'MarkerSize', 30);
    text(xs(r(i)),ys(r(i)),int2str(r(i)));
    text(xs(c(i)),ys(c(i)),int2str(c(i)));
  end
end
