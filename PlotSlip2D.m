% Initialization
clc; clear; close all;

% Set default colormap
map1 = flipud(hot);
set(0, 'DefaultFigureColormap', map1);

MU = 30e9; % Shear modulus

% Fault parameters, edit based on the input file
DXZ = 2; % Grid spacing
DEPTH_TOP = 0 * ones(1, 10); % Depth at the top of the fault
WIDTH = 26 * ones(1, 10); % Width of the fault
slip_names = {'s01_slip.dat','s02_slip.dat','s03_slip.dat'};% Slip data files

% Initialize arrays
nFaults = numel(slip_names);
momentArray = zeros(nFaults, 1);
magnitudeArray = zeros(nFaults, 1);

% Custom colormap
iHot = flipud(hot);
% Loop through each fault
max_slip = 0;

for i = 1:nFaults
    % Read fault slip data
    formatStr = repmat('%f ', 1, 16);
    data = read_txt(slip_names{i}, formatStr, 16, 1);

    % Extract and reshape data
    dipAngle = data(1, 12);
    zSize = round(WIDTH(i) / DXZ);
    xSize = round(size(data, 1) / zSize);
    sSlip = reshape(data(:, 8), zSize, xSize);
    dSlip = reshape(data(:, 9), zSize, xSize);
    tSlip = reshape(data(:, 10), zSize, xSize);

    % Calculate depth and x-axis
    depthAxis = DEPTH_TOP(i) + (0:zSize-1) * DXZ * sind(dipAngle) + DXZ * 0.5 * sind(dipAngle);
    xa = (xSize:-1:1) * DXZ;
    
    if max(tSlip(:))>max_slip
        max_slip = max(tSlip(:));
    end

    % Plotting single-fault plane
    figure;
    imagesc(xa, depthAxis, tSlip);
    colorbar;
    hold on;
    quiver(repmat(xa, zSize, 1), repmat(depthAxis', 1, xSize), sSlip, dSlip, '-k', 'filled', 'ShowArrowHead', 'on', 'LineWidth', 0.5, 'Color', '#00a8ff');
    hold off;
    xlabel('Distance along strike (km)');
    ylabel('Depth along dip (km)');
    set(gca, 'ylim', [0 WIDTH(1)], 'LineWidth', 0.5, 'FontSize', 18, 'FontName', 'Arial');
    box on;
    axis image;
    set(gcf, 'Position', [0, 0, 1100, 800]);

    % define the maximum slip, edit based on the 3d-slip
    % clim([0, 6]);

    exportgraphics(gca,  ['./plane-', num2str(i),'.png'], 'Resolution', 300);
    close all;
    
    % Moment and magnitude calculations
    momentArray(i) = MU * DXZ^2 * sum(tSlip(:)) * 1e6;
    magnitudeArray(i) = (log10(momentArray(i)) - 9.1) * 2/3;
end

% Total moment and magnitude
totalMoment = sum(momentArray);
totalMagnitude = (log10(totalMoment) - 9.1) * 2/3;

% Display and save results
disp(['Mw:', num2str(totalMagnitude)]);
fid = fopen('Mw.txt', 'w');
fprintf(fid, '%.3f', totalMagnitude);
fclose(fid);

