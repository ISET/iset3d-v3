function thisR = recipeSet(thisR, param, val, varargin)
% Set a recipe class value
%
% Syntax
%   thisR = recipeSet(thisR, param, val, varargin)
%
% Description:
%   The recipe class manages the PBRT rendering parameters.  The class
%   has many fields specifying camera and rendering parameters. This
%   method is only capable of setting one parameter at a time.
%
% Parameter list (in progress, many more to be added)
%
%   Data management
%    outputfile
%    inputfile
%
%  Scene and camera
%    camera
%    object distance (also focus distance)
%    exposure time
%
%  Film/sensor
%    film diagonal
%    film distance
%    film resolution
%    rays per pixel
%
%  Lens
%    lensfile - json format for omni case.  dat format for realistic.
%
%  Rendering
%    nbounces
%
% BW ISETBIO Team, 2017
%
% PBRT information that explains man
% Generally
% https://www.pbrt.org/fileformat-v3.html#overview
%
% Specifically 
% https://www.pbrt.org/fileformat-v3.html#cameras
%
% See also
%    recipeGet

% Examples:
%{
%}

%% Set up

if isequal(param,'help')
    doc('recipe.recipeSet');
    return;
end

%% Parse
p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('param',@ischar);
p.addRequired('val');

p.addParameter('lensfile','dgauss.22deg.12.5mm.dat',@(x)(exist(x,'file')));

p.parse(thisR, param, val);
param = ieParamFormat(p.Results.param);

%% Act
switch param
    
    % Rendering and Docker related
    case {'outputfile'}
        % thisR.set('outputfile',fullfilepath);
        %
        % The outputfile has a default initial string.  When we set,
        % we check that the new directory exists. If not, we make it.
        % If there were files in the previous directory we copy them
        % to the new directory.  Maybe there should be an option to
        % stop the copy.
        %
        % I think it is strange that we are doing this in a set. (BW).
        
        currentDir = fileparts(thisR.outputFile);
        newDir     = fileparts(val);
        if ~exist(newDir,'dir'), mkdir(newDir); end
        
        % Are we changing the output directory?  On the MAC, directory case
        % is not respected, so ...
        if isequal(lower(currentDir),lower(newDir))
            % Nothing needs to be done
        else
            % We start copying from the current to the new
            if ~exist(currentDir,'dir')
                % No files to be copied
            else
                fprintf('Output directory changed. Copying files from %s to %s \n',...
                    currentDir,newDir);
                copyfile(currentDir,newDir);
                rmdir(currentDir,'s');
            end
        end
        thisR.outputFile = val;
        
    case {'inputfile'}
        % thisR.set('input file',filename);
        val = which(val);
        thisR.inputFile = val;
        if ~exist(val,'file'), warning('No input file found yet'); end
    case {'exporter'}
        % thisR.set('exporter',val);
        % a string that identifies how the PBRT file was build
        % We have 'C4D','Copy','Unknown'
        thisR.exporter = val;
    case 'renderedfile'
        % thisR.set('rendered file',fname);
        % Set the full path
        thisR.renderedfile = val;

        % Scene parameters
    case 'objectdistance'
        % The 'from' spot, is the camera location.  The 'to' spot is
        % the point the camera is looking at.  Both are specified in
        % meters.
        %
        % This routine adjusts the the 'from' position, moving the
        % camera position. It does so by keeping the 'to' position the
        % same, so the camera is still looking at the same location.
        % Thus, the point of this set is to move the camera closer or
        % further from the 'to' position.
        %
        % What is the relationship to the focal distance?  If we move
        % the camera, the focal distance is always with respect to the
        % camera, right?
        
        % Unit length vector between from and to.
        objDirection = thisR.get('object direction');
        
        % Scale the unit length vector to match val, thus setting the
        % distance between 'from' and 'to'.  This adjust the 'from'
        % (camera) position, but not the object position in the scene.
        thisR.lookAt.from = thisR.lookAt.to + objDirection*val;
        % warning('Object distance may not be important');
        
    case {'focusdistance','focaldistance'}
        % lens.set('focus distance',m)
        %
        % This is the distance (m) to the object in the scene that
        % will be in focus.  The film distance is derived by PBRT from
        % this parameter.  It is possible that there is no film
        % distance for certain (say very near) focus distances.
        %
        % This variable is related to the lookat settings.  That
        % parameter says where the camera is pointing.  But the
        % distance to the object (objectdistance) may not be the same
        % as this focus distance. That is because it is possible to
        % look at an object but have it not be the object that is in
        % focus.
        %
        % Depending on the camera type, the parameter name is either
        % focusdistance or focaldistance. Historical annoyance in PBRT.
        if isequal(thisR.camera.subtype,'pinhole')||...
                isequal(thisR.camera.subtype,'perspective')
            thisR.camera.focaldistance.value = val;
            thisR.camera.focaldistance.type = 'float';
        else
            % When there is a lens.  Omni.  Realistic.
            thisR.camera.focusdistance.value = val;
            thisR.camera.focusdistance.type = 'float';
        end
        
        % Camera
    case 'camera'
        % Initialize a camera type with default parameters
        % To adjust the parameters use recipe.set() calls
        thisR.camera = piCameraCreate(val,'lensFile',p.Results.lensfile);
        
        % For the default camera, the film size is 35 mm
        thisR.set('film diagonal',35);
        
    case 'cameratype'
        thisR.camera.subtype = val;
        
    case {'cameraexposure','exposuretime'}
        % Normally, openShutter is at time zero
        thisR.camera.shutteropen.type  = 'float';
        thisR.camera.shutterclose.type = 'float';
        try
            openShutter = thisR.camera.shutteropen.value;
        catch
            openShutter = 0;
            thisR.camera.shutteropen.value = 0;
        end
        
        % Shutter duration in sec
        thisR.camera.shutterclose.value = val + openShutter;
        
        % Lens related
    case 'lensfile'
        % lens.set('lens file',val)   (string)
        % Should be the json file defining the camera.
        thisR.camera.lensfile.value = val;
        thisR.camera.lensfile.type = 'string';

    case {'lensradius'}
        % lens.set('lens radius',val (mm))
        %
        % Should only be set for perspective cameras
        %
        if isequal(thisR.camera.subtype,'perspective')
            thisR.camera.lensradius.value = val;
            thisR.camera.lensradius.type = 'float';
        else
            warning('Lens radius is set for perspective camera.  Use aperture diameter for omni');
        end
        
    case {'aperture','aperturediameter'}
        % lens.set('aperture diameter',val (mm))
        %
        % Set 'aperture diameter' should look at the aperture in the
        % lens file, which represents the largest possible aperture.
        % It should not allow a value bigger than that.  (ZL/BW).
        
        % Throw a warning for perspective camera
        if isequal(thisR.camera.subtype,'pinhole') ||...
                isequal(thisR.camera.subtype,'perspective')
            warning('Perspective/pinhole camera - setting "lens radius".')
            thisR.set('lens radius',val/2);
            return;
        end
        
        thisR.camera.aperturediameter.value = val;
        thisR.camera.aperturediameter.type = 'float';
    case 'fov'
        % This sets a horizontal fov
        % We should check that this is a pinhole, I think
        % This is only used for pinholes, not realistic camera case.
        if isequal(thisR.camera.subtype,'pinhole')||...
                isequal(thisR.camera.subtype,'perspective')
            if length(val)==1
                thisR.camera.fov.value = val;
                thisR.camera.fov.type = 'float';
            else
                % if two fov is given [hor, ver], we should resize film
                % acoordingly
                filmRes = thisR.get('film resolution');
                fov = min(val);
                % horizontal resolution/ vertical resolution
                resRatio = tand(val(1)/2)/tand(val(2)/2);
                if fov == val(1)
                    thisR.set('film resolution',[max(filmRes)*resRatio, max(filmRes)]);
                else
                    thisR.set('film resolution',[max(filmRes), max(filmRes)/resRatio]);
                end
                thisR.camera.fov.value = fov;
                thisR.camera.fov.type = 'float';
                disp('film ratio is changed!')
            end
        else
            warning('fov not set for camera models');
        end
    case 'diffraction'
        thisR.camera.diffractionEnabled.value = val;
        thisR.camera.diffractionEnabled.type = 'bool';
        
    case 'chromaticaberration'
        % Enable chrommatic aberration, and potentially set the number
        % of wavelength bands.  (Default is 8).
        %   thisR.set('chromatic aberration',true);
        %   thisR.set('chromatic aberration',false);
        %   thisR.set('chromatic aberration',16);
        
        % Enable or disable
        thisR.camera.chromaticAberrationEnabled.type = 'bool';
        
        if isequal(val,false)
            thisR.camera.chromaticAberrationEnabled.value = 'false';
            return;
        elseif isequal(val,true)
            thisR.camera.chromaticAberrationEnabled.value = 'true';
            val = 8;
        elseif isnumeric(val)
            thisR.camera.chromaticAberrationEnabled.value = 'true';
        else
            error('Unexpected type for val.  %s\n',class(val));
        end
        
        % Enabled, so set proper integrator
        thisR.integrator.subtype = 'spectralpath';
        
        % Set the bands.  These are divided evenly into bands between
        % 400 and 700 nm. There are  31 wavelength samples, so we
        % should not have more than 30 wavelength bands
        thisR.integrator.numCABands.value = min(30,val);
        thisR.integrator.numCABands.type = 'integer';
        
    case 'autofocus'
        % Should deprecate this.  Let's run it for a while and see how
        % often it turns up.
        %
        % thisR.set('autofocus',true);
        % Sets the film distance so the lookAt to point is in good focus
        warning('Bad autofocus set in recipe.  Fix!');
        if val
            fdist = thisR.get('focal distance');
            if isnan(fdist)
                error('Camera is probably too close (%f) to focus.',thisR.get('object distance'));
            end
            thisR.set('film distance',fdist);
        end
        
        % Camera position related.  The units are in ????
    case 'lookat'
        % Includes the from, to and up in a struct
        if isstruct(val) &&  isfield(val,'from') && isfield(val,'to')
            thisR.lookAt = val;
        end
    case 'from'
        thisR.lookAt.from = val;
    case 'to'
        thisR.lookAt.to = val;
    case 'up'
        thisR.lookAt.up = val;
        
        % Rendering related
    case{'maxdepth','bounces','nbounces'}
        % Eliminated warning Nov. 11, 2018.
        if(~strcmp(thisR.integrator.subtype,'path')) &&...
                (~strcmp(thisR.integrator.subtype,'bdpt'))
            disp('Changing integrator sub type to "bdpt"');
            
            % When multiple bounces are needed, use this integrator
            thisR.integrator.subtype = 'bdpt';
        end
        thisR.integrator.maxdepth.value = val;
        thisR.integrator.maxdepth.type = 'integer';
        
        % Microlens
    case 'microlens'
        % Not sure about what this means.  It is on or off
        thisR.camera.microlens_enabled.value = val;
        thisR.camera.microlens_enabled.type = 'float';
    case 'nmicrolens'
        % Number of microlens/pinhole samples for a light field camera
        %
        if length(val) == 1, val(2) = val(1); end
        thisR.camera.num_pinholes_h.value = val(1);
        thisR.camera.num_pinholes_h.type = 'float';
        thisR.camera.num_pinholes_w.value = val(2);
        thisR.camera.num_pinholes_w.type = 'float';
    case 'lightfieldfilmresolution'
        % This is printed out in the pbrt scene file
        nMicrolens = thisR.get('n microlens');
        nSubpixels = thisR.get('n subpixels');
        thisR.set('film resolution', nMicrolens .* nSubpixels);
    case 'nsubpixels'
        % How many pixels behind each microlens/pinhole
        % The type is not included because this is not passed to pbrt.
        thisR.camera.subpixels_h = val(1);
        thisR.camera.subpixels_w = val(2);
        
        % Film parameters
    case 'filmdiagonal'
        thisR.film.diagonal.type = 'float';
        thisR.film.diagonal.value = val;
    case {'filmdistance'}
        thisR.camera.filmdistance.type = 'float';
        thisR.camera.filmdistance.value = val;
    case 'filmresolution'
        % This is printed out in the pbrt scene file
        if length(val) == 1, val(2) = val(1); end
        thisR.film.xresolution.value = val(1);
        thisR.film.yresolution.value = val(2);
        thisR.film.xresolution.type = 'integer';
        thisR.film.yresolution.type = 'integer';
    case {'pixelsamples','raysperpixel'}
        % Sampler
        thisR.sampler.pixelsamples.value = val;
        thisR.sampler.pixelsamples.type = 'integer';
    case{'cropwindow','crop window'}
        thisR.film.cropwindow.value = [val(1) val(2) val(3) val(4)];
        thisR.film.cropwindow.type = 'float';
        
        % SUMO parameters stored in recipe metadata
    case {'trafficflowdensity'}
        thisR.metadata.sumo.trafficflowdensity = val;
    case {'traffictimestamp'}
        thisR.metadata.sumo.timestamp = val;
        
        % Getting read for camera level recipe information.
        % Not really used get.
    case {'camerabody'}
        thisR.camera = val.camera;
        thisR.film   = val.film;
        thisR.filter = val.filter;

        % Materials should be built up here.
    case {'materials'}
        thisR.materials = val;
    case {'materialsoutputfile'}
        thisR.materials.outputfile = val;
        
    % ZLY added fluorescent 
    case {'fluorophoreconcentration'}
        % thisR.set('fluorophore concentration',val,idx)
    case {'fluorophoreeem'}
        % thisR.set('fluorophore eem',val,idx)
        %
        % val - the name of the fluorophore.
        % idx - a numerical index to the material or it can be a string
        % which is the name of the mater 
        if isempty(varargin), error('Material name or index required'); end
        idx = varargin{1};

        % If the user sent a material name convert it to an index
        if ischar(idx), idx = piMaterialFind(thisR,'name',idx); end

        matName = val;
        switch thisR.recipeVer
            case 2
                % A modern recipe. So we set using modern methods.  The
                % function reads the fluorophore (fluorophoreRead) and
                % returns the EEM and sets it.  It uses the wavelength
                % sampling in the recipe to determine the EEM wavelength
                % sampling.
                thisR = piMaterialSet(thisR,idx,'fluorophore eem',val);
                
            otherwise
                % This is the original framing, before re-writing the
                % materials.list organization by Zheng.
                disp('Please update to version 2 of the recipe');
                disp('This will be deprecated');
                if ~isfield(thisR.materials.list, matName)
                    error('Unknown material name %s\n', matName);
                end
                if length(val) == 1
                    error('Donaldson matrix is empty\n');
                end
                if length(varargin) > 2
                    error('Accept only one Donaldson matrix\n');
                end
                
                fluorophoresName = val{2};
                if isempty(fluorophoresName)
                    thisR.materials.list.(matName).photolumifluorescence = '';
                    thisR.materials.list.(matName).floatconcentration = [];
                else
                    wave = 365:5:705; % By default it is the wavelength range used in pbrt
                    fluorophores = fluorophoreRead(fluorophoresName,'wave',wave);
                    % Here is the excitation emission matrix
                    eem = fluorophoreGet(fluorophores,'eem');
                    %{
                       fluorophorePlot(Porphyrins,'donaldson mesh');
                    %}
                    %{
                       dWave = fluorophoreGet(FAD,'delta wave');
                       wave = fluorophoreGet(FAD,'wave');
                       ex = fluorophoreGet(FAD,'excitation');
                       ieNewGraphWin;
                       plot(wave,sum(eem)/dWave,'k--',wave,ex/max(ex(:)),'r:')
                    %}
                    
                    % The data are converted to a vector like this
                    flatEEM = eem';
                    vec = [wave(1) wave(2)-wave(1) wave(end) flatEEM(:)'];
                    thisR.materials.list.(matName).photolumifluorescence = vec;
                end
        end
    case {'concentration'}
        matName = val{1};
        if ~isfield(thisR.materials.list, matName)
            error('Unknown material name %s\n', matName);
        end
        if length(val) == 1
            error('Concentration is empty\n');
        end
        if length(val) > 2
            error('Accept single number as concentration\n');
        end
        thisR.materials.list.(matName).floatconcentration = val{2};
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end
