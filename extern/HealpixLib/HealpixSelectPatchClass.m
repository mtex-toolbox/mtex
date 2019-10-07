% Get the class of patch that the specified point belongs 
% on the HEALPix tessellation
%
% Patch classes
% [class-id] [shape]    [location]
% 'o'        rectangle  pole
% 'r'        rectangle  polar cap
% 't'        triangle   equatorial belt
% 'p'        rhombus    polar cap
% 'e'        rhombus    equatorial belt
% 'b'        rhombus    border between polar cap and equatorial belt
% 'v'        invalid
function [class, INFO] = HealpixSelectPatchClass(n, i, j)

if i <= 2 * n
    % Northern Hemisphere
    INFO.i_n = i;
    INFO.is_south_pole = 0;
else
    % Southern Hemisphere
    INFO.i_n = 4 * n - i;
    INFO.is_south_pole = 1;
end

if INFO.i_n < n
    % polar cap
    INFO.is_polar_cap = 1;
else
    % equatorial belt
    INFO.is_polar_cap = 0;
end

% obviously belongs to the equatorial belt
if INFO.i_n >= n + 1
    class = 'e';
    return
end

% belongs to the pole rectangle
if INFO.i_n <= 1
    class = 'o';
    return
end

% width of the partition
if INFO.i_n <= n
    part_width = INFO.i_n;
else
    part_width = n;
end

% partition number within the porlar cap
INFO.polar_part = fix(j / part_width);
% intra-partition index
INFO.polar_intra_part = j - part_width * INFO.polar_part;

if INFO.polar_part >= 4 && INFO.polar_intra_part ~= 0
    class = 'v';
    return
end

% integer part of the intra-partition index
INFO.int_polar_intra_part = fix(INFO.polar_intra_part);
% decimal part of the intra-partition index
INFO.decimal_polar_intra_part = INFO.polar_intra_part - INFO.int_polar_intra_part;
% integer part of the i_n
INFO.int_i_n = fix(INFO.i_n);
% decimal part of the i_n
INFO.decimal_i_n = INFO.i_n - INFO.int_i_n;

% belongs to the equatorial belt
if INFO.i_n >= n
    if INFO.decimal_polar_intra_part < 1 - INFO.decimal_i_n
        if INFO.polar_intra_part < 1
            class = 't';
        else
            class = 'b';
        end
    else
        class = 'e';
    end
    return
end

% gradient of the border
grad = INFO.polar_part;
% beginning position of the partition
part_begin = grad * (INFO.i_n - 1) + grad;

% belongs to the border between the partitions in polar cap
if part_begin <= j && j <= part_begin + 1
    class = 'r';
    return
else
    class = 'p';
end

if INFO.i_n > n - 1
    grad = INFO.polar_part;
    begin_org_j = fix(j - grad * INFO.decimal_i_n);
    begin_j = grad * INFO.decimal_i_n + begin_org_j;
    end_j = (grad + 1) * INFO.decimal_i_n + begin_org_j;
    if begin_j <= j && j < end_j
        class = 'b';
    end
end
