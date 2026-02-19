% test funcitonalities of S2FunMLS class for various settings, 
% as well as the interaction with other classes in all those settings

%% approximate real function, complex function, vector-valued function from
%   values on random nodes
% at the same time this tests proper handling of arrays of S2FunMLS

cs = crystalSymmetry('222');
% cs = crystalSymmetry('1');

% test functions
f(1) = S2Fun.smiley;
f(2) = complex(0,1) * f(1) - f(1) .* f(1);
f(3) = S2FunHarmonic(2 * rand(64, 1, 1) - 1);
f(4:6) = S2FunHarmonic(2 * rand(32, 1, 3) - 1);
f = S2FunHarmonicSym.quadrature(f, cs); 
f = reshape(f, 3, 1, 2);
figure(1); plot(f); colorbar;

% grid for the test function, values on the grid
N = 1e4;
v = vector3d.rand(1, N, 2);
f_values = f.eval(v);
f = squeeze(f);

% test nodes
w = vector3d.rand(1e4);
f_values_w = f.eval(w);


%% test with standard parameters only
sF = S2FunMLS(v, f_values);
% sF.detectOutliers = true;
% sF.outlierDetectionRange = 3;
figure(2); plot(sF); colorbar;

[vals, conds] = sF.eval(w);
disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));

%% same test, but with range search instead of knn search
sF.delta = sF.compute_delta() * 2;
figure(2); plot(sF); colorbar;
[vals, conds] = sF.eval(w);
disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));
sF.delta = 0;


%% test with antipodal option 
% f = @(v)(sin(v.x).^2 .* cos(v.y) + tan(v.z.^2));
f = S2FunHarmonic(rand(60,1),'antipodal');
figure(1); plot(f, '3d'); colorbar;

f_values = f.eval(v);
sF = S2FunMLS(v, f_values);
sF.degree = 3;
sF.antipodal = f.antipodal;
figure(2); plot(sF, '3d'); colorbar;
[vals, conds] = sF.eval(w);
f_values_w = f.eval(w);

disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));

%% test antipodal option with range search 
sF.degree = 3;
sF.delta = sF.compute_delta * 1;
figure(2); plot(sF, '3d'); colorbar;
[vals, conds] = sF.eval(w);
f_values_w = f.eval(w);
sF.delta = 0;

disp('maximal errors: ');
disp(max(abs(vals - f_values_w)));
disp('maximal condition numbers: ');
disp(max(conds));

%% test various parameter settings for the same test function
w2 = vector3d.rand(1e3);
f = S2FunHarmonic(2 * rand(40,1) - 1);
f = @(v)(real(f.eval(v)));
f = S2FunHarmonic(f);
f_values = f.eval(v);

flags = {'centered', 'monomials', 'subsample', 'tangent'};
marker = logical(dec2bin((0:15)') - '0');

mls_values = zeros(numel(w2), 16);
mls_conds = zeros(numel(w2), 16);

clear sF;
sF = cell(16,1);
for i = 1 : 16
  % tangent need monomials
  if (mod(i+2,4) == 0)
    continue;
  end

  % 'bla' avoids empty applied_flags for i = 1
  applied_flags = ['bla', flags(marker(i,:))];
  numflags = sum(marker(i,:));
  sF{i} = S2FunMLS(v, f_values, applied_flags{:});
  % sF{i}.delta = 0;
  % sF{i}.delta = sF{i}.compute_delta() * 2;
  [mls_values(:,i), mls_conds(:,i)] = sF{i}.eval(w2);
end

errors = abs(mls_values - f.eval(w2));
errors(:, [2, 6, 10, 14]) = 0;
disp('maximal errors: ');
disp(max(errors, [], 1));
disp('maximal condition numbers: ');
disp(max(conds, [], 1));

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
figure(1); scatter(v, f_values); colorbar;

sF = S2FunMLS(v, f_values);
sF.antipodal = true;
figure(2); plot(sF); colorbar;

%% test annoying data - identify and remove outliers 
%   (technically they do not get removed, but their weight gets reduced to
%    almost zero)
sF = S2FunMLS(v, f_values, 'monomials', 'centered', 'degree', 3);
sF.antipodal = true;
sF.detectOutliers = true;
sF.outlierDetectionRange = 7;
% sF.stableFind = true; 
sF.regularize = true;
% sF.regularizationOptions = [sF.regularizationOptions, 'Qgood', 1, 'Qbad', 2, 'p', 3, 'q', 3, 'lambda_min', 1e-4,'lambda_max',1e-2];
sF.regularizationOptions = [sF.regularizationOptions, 'Qgood', 0, 'Qbad', 5, 'lambda_max', 1e-2, 'lambda_min', 1e-18, 'basis_weights', sF.compute_basis_weights.^4];

% use these lines for maximum stability
% sF.monomials = true;
% sF.centered = true;

figure(2); plot(sF); colorbar;

% check condition numbers
w = vector3d.rand(10000);
[~, conds] = sF.eval(w);
disp(max(conds));

%% same as before, but with range search instead
sF.delta = sF.compute_delta();
figure(2); plot(sF); colorbar;
sF.delta = 0;
% diff = f_values - sF.eval(v);
% disp(max(abs(diff)));

%% check if the previous 2 test get better if we have outliers on a regular grid
% create test function
v = fibonacciS2Grid(N);
f = S2FunHarmonic(2 * rand(40, 1) - 1);
figure(1); plot(f); colorbar;

% make 1% of the data noisy
f_values = f.eval(v);
num_outliers = round(numel(v) * .01);
I = randperm(numel(v), num_outliers);
noisy_values = f_values;
noisy_values(I) = 100 * mean(abs(f_values)) * (2 * rand(num_outliers, 1) - 1);

% use these lines for maximum stability
sF.monomials = true;
sF.centered = true;

% MLS without outlier detection
sF = S2FunMLS(v, noisy_values, 'centered', 'monomials');
figure(2); plot(sF); colorbar;

% MLS with outlier detection
sF2 = S2FunMLS(v, noisy_values, 'centered', 'monomials');
sF2.detectOutliers = true;
sF2.outlierDetectionRange = 7;
figure(3); plot(sF2); colorbar;

%% same as before, but now with range search on the regular grid

% MLS without outlier detection
sF.delta = sF.compute_delta();
figure(2); plot(sF); colorbar;

% MLS with outlier detection
sF2.delta = sF2.compute_delta();
figure(3); plot(sF2); colorbar;

