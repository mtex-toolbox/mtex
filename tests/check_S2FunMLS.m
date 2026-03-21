% test funcitonalities of S2FunMLS class for various settings, 
% as well as the interaction with other classes in all those settings

%% options

% symmetry
% cs = crystalSymmetry('222');
cs = crystalSymmetry('1');

%% approximate real function, complex function, vector-valued function from
%   values on random nodes
% at the same time this tests proper handling of arrays of S2FunMLS

% test functions
f(1) = S2Fun.smiley;
f(2) = complex(0,1) * f(1) - f(1) .* f(1);
f(3) = S2FunHarmonic(2 * rand(64, 1, 1) - 1);
f(4:6) = S2FunHarmonic(2 * rand(32, 1, 3) - 1);
% f = S2FunHarmonicSym.quadrature(f, cs); 
f = reshape(f, 3, 1, 2);
myplot(f, 1);

% grid for the test function, values on the grid
N = 1e4;
v = vector3d.rand(1, N, 2);
f_values = f.eval(v);
f = squeeze(f);

% test nodes
w = vector3d.rand(1e4);
f_values_w = f.eval(w);


%% test with standard parameters only
S2F = S2FunMLS(v, f_values);
% S2F.detectOutliers = true;
% S2F.outlierDetectionRange = 3;
myplot(S2F, 2);

[vals, conds] = S2F.eval(w);
disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));

%% same test, but with range search instead of knn search
S2F.delta = S2F.compute_delta() * 1.2;
myplot(S2F, 2);
[vals, conds] = S2F.eval(w);
disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));
S2F.delta = 0;


%% test with antipodal option 
% f = @(v)(sin(v.x).^2 .* cos(v.y) + tan(v.z.^2));
f = S2FunHarmonic(rand(60,1),'antipodal');
myplot(f, 1);

f_values = f.eval(v);
S2F = S2FunMLS(v, f_values);
S2F.degree = 3;
S2F.antipodal = f.antipodal;
myplot(S2F, 2);
[vals, conds] = S2F.eval(w);
f_values_w = f.eval(w);

disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));

%% test antipodal option with range search 
S2F.degree = 3;
S2F.delta = S2F.compute_delta * 1;
myplot(S2F, 2);
[vals, conds] = S2F.eval(w);
f_values_w = f.eval(w);
S2F.delta = 0;

disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));

%% test various parameter settings for the same test function
w2 = vector3d.rand(1e2);
f = S2FunHarmonic(2 * rand(40,1) - 1);
f = @(v)(real(f.eval(v)));
f = S2FunHarmonic(f);
f_values = f.eval(v);

opts = {'centered'; 'monomials'; 'tangent'; 'regularize'};
numopts = numel(opts);
truefalse_idx = 2 * (1 : numopts)';
opt_idx = truefalse_idx - 1;
marker = logical(dec2bin((0 : 2^numopts-1)') - '0');

flag_template = cell(2*numopts, 1);
flag_template(opt_idx) = opts(1 : numopts)';

extra_flags = {'detectOutliers'; 'subsample'};
extra_marker = zeros(size(extra_flags));
num_extra_flags = numel(extra_flags);
mls_values = zeros(numel(w2), 2^numopts * 2^num_extra_flags);
mls_conds = zeros(numel(w2), 2^numopts * 2^num_extra_flags);
clear S2F;
S2F = cell(2^numopts * 2^num_extra_flags, 1);

for i = 1 : numel(S2F)

  marker_idx = mod(i-1, 2^numopts) + 1;
  truefalse = num2cell(marker(marker_idx,:), 1);
  flag_template(truefalse_idx) = truefalse;

  for j = 1 : numel(extra_flags)
    extra_marker(j) = logical(mod(floor((i-1) / 2^(numopts+j-1)), 2));
    extra_marker(j) = logical(mod(floor((i-1) / 2^(numopts+j-1)), 2));
  end

  current_flags = [flag_template; extra_flags(extra_marker > 0)];
  S2F{i} = S2FunMLS(v, f_values, current_flags{:});
  % S2F{i}.delta = 0;
  % S2F{i}.delta = S2F{i}.compute_delta() * 1;
  [mls_values(:,i), mls_conds(:,i)] = S2F{i}.eval(w2);
  % disp(i / numel(S2F) * 100);
  disp(i);
  disp(current_flags);
end

errors = abs(mls_values - f.eval(w2));
errors(:, [2, 6, 10, 14]) = 0;
disp('maximal errors: ');
disp(max(errors, [], 1));
disp('maximal condition numbers: ');
disp(max(mls_conds, [], 1));

%% test annoying data - standard
try 
  pf = pf{1};
catch 
  mtexdata dubna; 
  pf = pf{1};
end
v = pf.r(:);
f_values = pf.intensities(:);
v2 = [-v; v];

figure(1); 
scatter(v, f_values); 
colormap(WhiteJetColorMap);
mtexColorbar;

S2F = S2FunMLS(v, f_values);
S2F.antipodal = true;
myplot(S2F, 2);

%% test annoying data - identify and remove outliers 
%   (technically they do not get removed, but their weight gets reduced to
%    almost zero)
S2F = S2FunMLS(v, f_values, 'degree', 4);
S2F.w = @(t)(S2F.w(t).^2);
S2F.antipodal = true;

myplot(S2F, 2);

% check condition numbers
w = vector3d.rand(10000);
[~, conds] = S2F.eval(w);
disp(max(conds));

%% same as before, but with range search instead
S2F.delta = S2F.compute_delta();
myplot(S2F, 2);
S2F.delta = 0;
% diff = f_values - S2F.eval(v);
% disp(max(abs(diff)));

%% check if the previous 2 test get better if we have outliers on a regular grid
% create test function
v = fibonacciS2Grid(N);
f = S2FunHarmonic(2 * rand(40, 1) - 1);
myplot(f, 1);

% make 1% of the data noisy
f_values = f.eval(v);
num_outliers = round(numel(v) * .01);
I = randperm(numel(v), num_outliers);
noisy_values = f_values;
noisy_values(I) = 1 * mean(abs(f_values)) * (2 * rand(num_outliers, 1) - 1);

% MLS without outlier detection
S2F = S2FunMLS(v, noisy_values);
myplot(S2F, 2);

% MLS with outlier detection
S2F2 = S2FunMLS(v, noisy_values);
S2F2.detectOutliers = true;
S2F2.outlierDetectionRange = 7;
myplot(S2F2, 3);

%% same as before, but now with range search on the regular grid

% MLS without outlier detection
S2F.delta = S2F.compute_delta();
myplot(S2F, 2);

% MLS with outlier detection
S2F2.delta = S2F2.compute_delta();
myplot(S2F2, 3);

%% helper functions, especially for plotting

function myplot(fun, fignum)
  figure(fignum);
  plot(fun, 'upper');
  colormap(WhiteJetColorMap);
  mtexColorbar;
end