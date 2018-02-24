%% s_viewBurst
%

chdir(fullfile(piRootPath,'local','chess','renderings'));
pngFiles = dir('*.png');
img = imread(pngFiles(8).name);
vcNewGraphWin; imagesc(img); colormap(gray); truesize
