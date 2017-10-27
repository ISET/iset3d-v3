%% s_focusLensTable
%
% Make a table in which rows are lens, columns are distances, and entries are
% the focal length.  So, 
%
%   T(whichLens,dist) = focalDistance
%
% Plot the focal distance vs. the object distance.  You can select from
% different lenses in the pbrt2ISET data/lens directory.
%
% BW SCIEN Stanford, 2017

%%  All the lenses in the pbrt2ISET directory

lensDir = fullfile(piRootPath,'data','lens');

% wide, tessar, fisheye, dgauss, telephoto, 2el, 2EL
lensFiles = dir(fullfile(lensDir,'dgauss*.dat'));   

dist = logspace(0.1,4,30);

%% Calculate the focal distances

focalDistance = zeros(length(lensFiles),length(dist));

for ii=1:length(lensFiles)
    fname = fullfile(lensDir,lensFiles(ii).name);
    for jj=1:length(dist)
        focalDistance(ii,jj) = focusLens(lensFiles(ii).name,dist(jj));
    end
end

%%  When the distance is too small, we can't get a good focus.

% In that case, the distance is negative
vcNewGraphWin;
focalDistance(focalDistance < 0) = NaN;
loglog(dist,focalDistance');
xlabel('Object distance (mm)'); ylabel('Focal length (mm)');
grid on

%%
