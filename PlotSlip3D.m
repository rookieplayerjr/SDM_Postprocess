% Initialization
clc; clear; close all;

% Set default colormap
map1 = flipud(hot);
set(0, 'DefaultFigureColormap', map1);

% define slip file names
slip_names = {'s01_slip.dat','s02_slip.dat','s03_slip.dat'};

% Create a new figure
f = figure;

% Process and plot slip data
data = import_slip_data(slip_names);
plot_single_slip(data, flipud(hot));

exportgraphics(gcf,'.\3d.png');


%% % --- Subfunctions --- %

function data = import_slip_data(slip_names)

data = [];
for i = 1:numel(slip_names)
    data1 = read_txt(fullfile(slip_names{i}), '%f', 16, 1);
    data = [data;data1];
end

end

function plot_single_slip(data)

lat_arr = data(:,1);
lon_arr = data(:,2);
depth_arr = data(:,3);
length_arr = data(:,6);
width_arr = data(:,7);
slip_arr = data(:,10);
stri_arr = data(:,11);
dip_arr = data(:,12);


for k = 1:size(data, 1)
    [lonlat1, rect_depth] = calc_patch_coordinates(lon_arr(k), lat_arr(k), width_arr(k), length_arr(k), dip_arr(k), depth_arr(k), stri_arr(k));
    rect_ll=[lonlat1,lonlat1(:,1)]';
    s = patch(rect_ll(:,1),rect_ll(:,2),-rect_depth,slip_arr(k),'LineWidth',0.1);
    % s.EdgeColor = 'none';
end

hold on;

customize_plot(max(slip_arr));

end

function customize_plot( max_v)

colormap(flipud(hot));
grid on;
box on;
xlabel('Longitude'); ylabel('Latitude'); zlabel('Depth(km)');
title('Fault slip distribution (m)');
clim([0, max_v]);
set(gcf, 'Position', [1, 1, 1300, 700]);
%     xlim([97.4, 99.4]); ylim([34.3, 34.85]);
colorbar

end

function [lonlat, rect_depth] = calc_patch_coordinates(lon, lat, width, length, dip, depth, strike)
xlen_tmp = width * cosd(dip);
ylen_tmp = length;

rect1 = [-xlen_tmp/2, -xlen_tmp/2, xlen_tmp/2, xlen_tmp/2;
    -ylen_tmp/2, ylen_tmp/2, ylen_tmp/2, -ylen_tmp/2];

% anti-clockwise rotation matrix
rote_cw = [cosd(strike), sind(strike); -sind(strike), cosd(strike)];

% rotate
rect_rote = rote_cw * rect1;

% convert local coordinates to latitude and longitude
lonlat = local2llh(rect_rote, [lon, lat]);

zlen_tmp = width * sind(dip);
rect_depth = [-zlen_tmp/2, -zlen_tmp/2, zlen_tmp/2, zlen_tmp/2, -zlen_tmp/2]' + depth;
rect_depth(rect_depth < 0) = 0;


end


