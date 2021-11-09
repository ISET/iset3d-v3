function [renderNoise, photonNoise, sensor, thisR] = piRenderNoise(varargin)
% Produce a curve showing how increasing rays per pixel reduces noise
%
% Synopsis
%    [renderNoise, photonNoise, sensor, thisR] = piRenderNoise(varargin)
%
% Brief description
%    Use PBRT with different numbers of rays per pixel and estimate render
%    noise.  
%
% Inputs
%   N/A
%
% Optional key/val
%   lens name  - ISETLens lens file
%   rays       - Vector of rays with a default [16 64 256 512 1024]
%   sensor     - Monochrome sensor.  Default is the ideal sensor
%   polydeg    - Polynomial degree.  Default is 1.  
%
% Outputs
%   renderNoise - vector noise levels, one for each ray count
%   photonNoise - scalar of the expected photon noise
%
% Description
%   We render a flat surface scene using PBRT.  We calculate the variance
%   in the flat surface rendering, imaged onto an ideal sensor.  If there
%   is no rendering noise, the output should be Poisson with mean equal to
%   variance (std^2).  If there is rendering noise then the renderNoise
%   will exceed the photonNoise.
%
% See Also

% Examples:
%{
  rays = [32 64 256];
  [rn, pn, sensor, flatR] = piRenderNoise('rays',rays);
  ieNewGraphWin; 
  plot(rays,rn,'-ok','Linewidth',2);
  line([rays(1), rays(end)],[pn, pn],'Color','k','Linestyle','--');
  grid on; xlabel('Rays per pixel'); ylabel('Noise');
%}

%% Parse the inputs

p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('recipe',[],@(x)(isa(x,'recipe')));
p.addParameter('lensname','dgauss.22deg.12.5mm.json',@(x)exist(x,'file'));
p.addParameter('rays',[64 256 512],@isvector);
p.addParameter('sensor',sensorCreateIdeal,@(x)(isequal(x.type,'sensor')));
p.addParameter('polydeg',1,@isnumeric);

p.parse(varargin{:});

lensname = p.Results.lensname;
rpp      = p.Results.rays;
sensor   = p.Results.sensor;
polydeg  = p.Results.polydeg;
thisR    = p.Results.recipe;

%% Build the scene

% Use the default, or the one the user sent in
if isempty(thisR)
    thisR = piRecipeDefault('scene name','flat surface');
    
    % Add the camera to the recipe
    c = piCameraCreate('omni','lens file',lensname);
    thisR.set('camera',c);
    
    % Set small film size.
    thisR.set('film diagonal',0.5);
    filmResolution = [128 32];
    thisR.set('film resolution',filmResolution);
end

% Get the oi to figure out the sensor field of view (size)
thisR.set('rays per pixel', 1);
thisOI = piWRS(thisR,'show',false);

%% Set up the sensor

sensor = sensorSet(sensor,'exp time',1e-3);
sensor = sensorSet(sensor,'fov',thisR.get('fov'),thisOI);
sz     = sensorGet(sensor,'size');

%% Loop on rays per pixel

renderNoise = zeros(size(rpp));
for ii=1:numel(rpp)
    thisR.set('rays per pixel',rpp(ii));
    oi = piWRS(thisR,'show',false);

    sensor = sensorCompute(sensor,oi);
    % We could go through a couple of lines, rather than just one.
    uData = sensorPlot(sensor,'electrons hline',round([1, sz(2)/2]),'no fig',true);
    
    % Not needed for the uniform patch. Could just use this
    %
    %   polyPredicted = mean(uData.pixData(:));
    %
    % Left in the linear polynomial anyway for historical reasons.  It may
    % go away some day.
    thisPoly      = polyfit(uData.pixPos,uData.pixData,polydeg);
    polyPredicted = polyval(thisPoly,uData.pixPos);
    
    % ieNewGraphWin; plot(uData.pixPos,uData.pixData,'o',uData.pixPos,polyPredicted,'-');
    photonNoise = sqrt(mean(uData.pixData));
    
    % disp([std(uData.pixData - polyPredicted), photonNoise])
    renderNoise(ii) = std(uData.pixData - polyPredicted);
end

end