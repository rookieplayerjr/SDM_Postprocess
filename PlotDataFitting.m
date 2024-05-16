clc; clear; close all;

% Set default colormap
map1 = jet;
set(0, 'DefaultFigureColormap', map1);

% Constants and Initialization
formatStr = repmat('%f ', 1, 16);
cols = 8;
skipCols = 1;

% define the output files names 
names = {'output_alos2.dat', 'output_at99_az.dat'};

% Process each data file
for i = 1:numel(names)
    PlotDataFile(names{i}, formatStr, cols, skipCols);
    exportgraphics(gcf,  [char(names{i}(1:end-4)),'.png'], 'Resolution', 300);
    close all;
end


% --- Functions Section ---

function PlotDataFile(fileName, formatStr, cols, skipCols)

% Read data
data = read_txt(fileName, formatStr, cols, skipCols);

% Extract relevant data columns
lat = data(:, 1);
lon = data(:, 2);
res = data(:, 4);
obs = data(:, 3);
model = obs - res;

% Display max and min values of observations
disp([fileName, ':', num2str(max(obs)), '/', num2str(min(obs))]);
scnsize = get(0,'ScreenSize');

gcf = figure;
set(gcf,'Position',scnsize);
% Plotting

tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% Common settings
fontSize = 12;
fontName = 'Arial';
lineWidth = 0.5;
markerSize = 30;
colorLimit = max(abs(obs));
% colorLimit = 5;

% Observed data plot
nexttile(1);
scatter(lon, lat, markerSize, obs, 'filled');
title('Observed', 'FontSize', fontSize, 'FontName', fontName);
clim([-colorLimit, colorLimit]);
ax(1) = gca;

hold on;
axis image
setCommonAxisProperties(ax(1), fontName, fontSize, lineWidth);

% Model data plot
nexttile(2);
scatter(lon, lat, markerSize, model, 'filled');
title('Model', 'FontSize', fontSize, 'FontName', fontName);
clim([-colorLimit, colorLimit]);
ax(2) = gca;
axis image
setCommonAxisProperties(ax(2), fontName, fontSize, lineWidth);

% Residual data plot
nexttile(3);
scatter(lon, lat, markerSize, res, 'filled');
title(['Residual (RMS:', num2str(rms(res)), ' cm)'], 'FontSize', fontSize, 'FontName', fontName);
clim([-colorLimit, colorLimit]);

ax(3) = gca;

axis image
% Colorbar and linking axes
colorbar;
linkaxes(ax);
setCommonAxisProperties(ax(3), fontName, fontSize, lineWidth);

orient(gcf, 'landscape');

sgtitle(fileName(1:4))
end

function setCommonAxisProperties(ax, fontName, fontSize, lineWidth)
hold on;
box on;
grid on;
xlim([96.5 100])
ylim([33.5 36])
set(ax, 'LineWidth', lineWidth, 'FontSize', fontSize, 'FontName', fontName);
end


function data_read=read_txt(filename,format_str,valid_cols,skip_row1)
%skip txt by sscanf %*s
%%%% read data from txt which could including data and txt together
if (nargin ==3)
    skip_row1=0;
elseif(nargin==4)

else
    error('input parameter error');
end

data_read=zeros(10,valid_cols);

fid=fopen(filename,'r');
countt=0;
idy=0;
while feof(fid)~=1
    countt=countt+1;
    str1=fgetl(fid);
    if(countt<=skip_row1)
        continue;
    end

    idy=idy+1;
    data_read(idy,:)=sscanf(str1,format_str);

end

fclose(fid);
end