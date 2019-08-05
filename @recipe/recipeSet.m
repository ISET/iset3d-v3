function thisR = recipeSet(thisR, param, val, varargin)
% Set a recipe class value
%
% Syntax
%   thisR = recipeSet(thisR, param, val, [varargin])
%
% Description:
%    The recipe class manages the PBRT rendering parameters. The class has
%    many fields specifying camera and rendering parameters. This method is
%    only capable of setting one parameter at a time.
%
%    *Please note that the list of parameter options below is
%    non-exhaustive, and that it is still being added to. Sections such as
%    film/sensor are not yet written out, as well as additional rendering
%    parameter options.
%
% Inputs:
%    thisR - Object. A recipe object.
%    param - String. A string indicating which parameter's value to change.
%            Some of the parameters available to set are as follows*:
%         outputfile         - String. A data management pair type. The
%                              full filepath to the output file.
%         inputfile          - String. A data management pair type. The
%                              full filepath to the input file.
%         objectDistance     - Numeric. A scene and camera pair type. The
%                              distance to the object.
%         camera             - Object. A scene and camera pair type. This
%                              is a camera object.
%         cameratype         - String. A scene and camera pair type. This
%                              is the subtype of the camera.
%         lensfile           - String. A lens pair type. The filename for
%                              an applicable lens file. This is a json file
%                              for omni case, and a dat file for realistic.
%         nbounces           - Numeric. A rendering pair type. The number
%                              of bounces for the light source. Also known
%                              as maxDepth, or bounces.
%         aperture           - Numeric. Also known as apertureDiameter,
%                              this is the diameter of the aperture.
%         filmDistance       - Numeric. The film distance.
%         focusDistance      - Numeric. The focus distance. Only in v3.
%         fov                - Numeric. The field of view, in degrees. Only
%                          works for pinhole cameras.
%         diffraction        - Numeric. The diffraction value. Only in v2.
%         chroAbb            - Varies. Either boolean or numeric. Also
%                              known as chromatic abberation. If numeric,
%                              assign value and set
%                              chromaticAbberationEnabled to true.
%                              Otherwise, set chromaticAbberation to the
%                              provided boolean value (if true, default
%                              value of chroAbb is 8).
%         autoFocus          - Boolean. Whether or not to automatically set
%                              the film distance so that the lookAt to
%                              point is in good focus.
%         lookat             - Struct. A camera position pair. A structure
%                              defining the lookAt paridigam, including
%                              from, to, & up coordinates.
%         from               - Matrix. A camera position pair. A 1x3 Matrix
%                              defining the from perspective in 3D space.
%         to                 - Matrix. A camera position pair. A 1x3 Matrix
%                              defining the to perspective in 3D space.
%         up                 - Matrix. A camera position pair. A 1x3 Matrix
%                              defining the up perspective in 3D space.
%         microLens          - Numeric. A microlens pair. If the microlens
%                              is enabled, a numeric value to represent the
%                              number of microlens/pinhole samples for the
%                              specified light field camera.
%         nMicroLens         - Numeric. A microlens pair. The number of
%                              pinhole samples for a light field camera.
%         lfFilmRes          - Varies. The value provided is unused.
%                              Resolution is calculated by dot multiplying
%                              the values of nMicroLens and nSubPixels.
%         nSubPixels         - Numeric. The numbr of pixels behind each
%                              microlens/pinhole.
%         filmResolution     - Matrix. A film pair. Either a 1x2 or 1x1
%                              numeric matrix (which is converted to 1x2)
%                              showcasing the film resolution for the scene
%         diagonal           - Numeric. Also known as filmDiagonal. The
%                              measurement of the diagonal across the
%                              resolution of the film.
%         raysPerPixel       - Numeric. A sampler pair. Also known as
%                              pixelSamples. The number of rays per pixel
%                              in the scene.
%         cropWindow         - Matrix. A 1x4 matrix representing the
%                              dimensions/coordinates of the cropped window
%         trafficflowdensity - Numeric. A numerical value representing the
%                              trafficflow's density.
%         trafficTimeStamp   - Numeric. The timestamp for the trafficflow.
%    val   - VARIES. The value type for the individual parameters above is
%            listed with each of their descriptions.
%
% Outputs:
%    thisR - Object. The modified recipe object.
%
% Optional key/value pairs:
%    None.
%
% Note:
%    * The optional key/value pairs section is still in progress
%    * PBRT information that explains man
%        Generally - https://www.pbrt.org/fileformat-v3.html#overview
%        Specifically - https://www.pbrt.org/fileformat-v3.html#cameras
%
% See Also:
%   recipeGet
%

% History:
%    XX/XX/17  BW   ISETBIO Team, 2017
%    04/19/19  JNM  Documentation pass
%    05/09/19  JNM  Merge with master
%    07/29/19  JNM  Rebase from master

% Examples
%{
    thisR.set('lensFile', 'dgauss.22deg.3.0mm.dat')
%}

%% Set up
if isequal(param, 'help')
    doc('recipe.recipeSet');
    return;
end

p = inputParser;
p.KeepUnmatched = true;

vFunc = @(x)(isequal(class(x), 'recipe'));
p.addRequired('thisR', vFunc);
p.addRequired('param', @ischar);
p.addRequired('val');
p.addParameter('lensfile', 'dgauss.22deg.12.5mm.dat', ...
    @(x)(exist(x, 'file')));

p.parse(thisR, param, val, varargin{:});

param = ieParamFormat(p.Results.param);

%% Act
switch param
    % Rendering and Docker related
    case {'outputfile'}
        % thisR.set('outputfile', fullfilepath);
        %
        % The outputfile has a default initial string. When we set, we
        % check that the new directory exists. If not, we make it. If there
        % were files in the previous directory we copy them to the new
        % directory. Maybe there should be an option to stop the copy.
        currentDir = fileparts(thisR.outputFile);
        newDir = fileparts(val);
        if ~exist(newDir, 'dir'), mkdir(newDir); end

        % Are we changing the output directory?
        if ~isequal(currentDir, newDir)
            % We start copying from the current to the new
            if exist(currentDir, 'dir')  % Has files? Copy them over!
                fprintf(strcat('Output directory changed. Copying ', ...
                    'files from %s to %s \n'), currentDir, newDir);
                copyfile(currentDir, newDir);
                rmdir(currentDir, 's');
            end
        end

        thisR.outputFile = val;

    case {'inputfile'}
        thisR.inputFile = val;

    % Scene and camera
    case 'objectdistance'
        % Changes the distance from the camera (from) to the object
        % pointed at by the camera (to).
        %
        % Adjusts the lookat 'from' field to match the distance in val.
        % This needs some more thought. At present this adjusts the
        % 'from' spot, which is where the camera is. It keeps the
        % direction the same, just scales it.
        
        % Unit length vector between from and to.
        objDirection = thisR.get('object direction');

        % Scale the unit length vector to match val, setting the
        % distance between from and to.
        newDirection = objDirection * val;
        thisR.lookAt.from = thisR.lookAt.to + newDirection;

    % Camera
    case 'camera'
        % Initialize a camera type with default parameters
        % To adjust the parameters use recipe.set() calls
        thisR.camera = piCameraCreate(val, 'lensFile', p.Results.lensfile);

        % For this camera, the film size should be
        thisR.set('film diagonal', 35);

    case 'cameratype'
        thisR.camera.subtype = val;

    case {'cameraexposure', 'exposuretime'}
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
        if thisR.version == 3
            thisR.camera.lensfile.value = val;
            thisR.camera.lensfile.type = 'string';
        elseif thisR.version == 2
            thisR.camera.specfile.value = val;
            thisR.camera.specfile.type = 'string';
        end

    case {'aperture', 'aperturediameter'}
        % This set should look at the aperture in the lens file, which
        % represents the largest possible aperture. It should not allow a
        % value bigger than that. (ZL/BW).
        thisR.camera.aperturediameter.value = val;
        thisR.camera.aperturediameter.type = 'float';

    case {'focusdistance'}
        % This is the distance to the object in the scene that will be in
        % focus. When this is set, the film distance is derived by PBRT.
        % It is possible that there is no film distance for certain (say
        % very near) focus distances.
        %
        % This variable is related to the lookat settings and we should
        % probably connect this with 'objectdistance'. Though it is
        % possible to look at an object but have it not be the object that
        % is in focus.
        %
        thisR.camera.focusdistance.value = val;
        thisR.camera.focusdistance.type = 'float';

    case 'fov'
        % This sets a horizontal fov
        % We should check that this is a pinhole, I think
        % This is only used for pinholes, not realistic camera case. 
        if isequal(thisR.camera.subtype,'pinhole') || ...
                isequal(thisR.camera.subtype,'perspective')
            if length(val) == 1
                thisR.camera.fov.value = val;
                thisR.camera.fov.type = 'float';
            else
                % if two fov is given [hor, ver], we should resize film
                % acoordingly
                filmRes = thisR.get('film resolution');
                fov = min(val);
                % horizontal resolution / vertical resolution
                resRatio = tand(val(1) / 2) / tand(val(2) / 2);
                if fov == val(1)
                    thisR.set('film resolution', ...
                        [max(filmRes) * resRatio, max(filmRes)]);
                else
                    thisR.set('film resolution', ...
                        [max(filmRes), max(filmRes) / resRatio]);
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
        % of wavelength bands. (Default is 8).
        % thisR.set('chromatic aberration', true);
        % thisR.set('chromatic aberration', false);
        % thisR.set('chromatic aberration', 16);

        % Enable or disable
        thisR.camera.chromaticAberrationEnabled.type = 'bool';

        if isequal(val, false)
            thisR.camera.chromaticAberrationEnabled.value = 'false';
            return;
        elseif isequal(val, true)
            thisR.camera.chromaticAberrationEnabled.value = 'true';
            val = 8;
        elseif isnumeric(val)
            thisR.camera.chromaticAberrationEnabled.value = 'true';
        else
            error('Unexpected type for val. %s\n', class(val));
        end

        % Enabled, so set proper integrator
        thisR.integrator.subtype = 'spectralpath';

        % Set the bands. These are divided evenly into bands between
        % 400 and 700 nm. There are  31 wavelength samples, so we
        % should not have more than 30 wavelength bands
        thisR.integrator.numCABands.value = min(30, val);
        thisR.integrator.numCABands.type = 'integer';

    case 'autofocus'
        % thisR.set('autofocus', true);
        % Sets the film distance so the lookAt to point is in good focus
        if val
            fdist = thisR.get('focal distance');
            if isnan(fdist)
                error('Camera is probably too close (%f) to focus.', ...
                    thisR.get('object distance'));
            end
            thisR.set('film distance', fdist);
        end

    % Camera position related
    case 'lookat'
        % Includes the from, to and up in a struct
        if isstruct(val) &&  isfield(val, 'from') && isfield(val, 'to')
            thisR.lookAt = val;
        end

    case 'from'
        thisR.lookAt.from = val;

    case 'to'
        thisR.lookAt.to = val;

    case 'up'
        thisR.lookAt.up = val;

    % Film parameters
    case 'filmdiagonal'
        thisR.film.diagonal.type = 'float';
        thisR.film.diagonal.value = val;

    case {'filmdistance'}
        thisR.camera.filmdistance.type = 'float';
        thisR.camera.filmdistance.value = val;

    % Rendering related
    case{'maxdepth', 'bounces', 'nbounces'}
        % Eliminated warning Nov. 11, 2018.
        if ~strcmp(thisR.integrator.subtype, 'path') && ...
                ~strcmp(thisR.integrator.subtype, 'bdpt')
            disp('Changing integrator sub type to "bdpt"');

            % When multiple bounces are needed, use this integrator
            thisR.integrator.subtype = 'bdpt';
        end
        thisR.integrator.maxdepth.value = val;
        thisR.integrator.maxdepth.type = 'integer';

    % Microlens
    case 'microlens'
        % Not sure about what this means. It is on or off
        thisR.camera.microlens_enabled.value = val;
        thisR.camera.microlens_enabled.type = 'float';

    case 'nmicrolens'
        % Number of microlens/pinhole samples for a light field camera
        if length(val) == 1, val(2) = val(1); end
        thisR.camera.num_pinholes_h.value = val(1);
        thisR.camera.num_pinholes_h.type = 'float';
        thisR.camera.num_pinholes_w.value = val(2);
        thisR.camera.num_pinholes_w.type = 'float';

    case {'lffilmres', 'lightfieldfilmresolution'}
        % This is printed out in the pbrt scene file
        nMicrolens = thisR.get('n microlens');
        nSubpixels = thisR.get('n subpixels');
        thisR.set('film resolution', nMicrolens .* nSubpixels);

    case 'nsubpixels'
        % How many pixels behind each microlens/pinhole
        % The type is not included because this is not passed to pbrt.
        thisR.camera.subpixels_h = val(1);
        thisR.camera.subpixels_w = val(2);

    % Film
    case 'filmresolution'
        % This is printed out in the pbrt scene file
        if length(val) == 1, val(2) = val(1); end
        thisR.film.xresolution.value = val(1);
        thisR.film.yresolution.value = val(2);

        thisR.film.xresolution.type = 'integer';
        thisR.film.yresolution.type = 'integer';

    case {'pixelsamples', 'raysperpixel'}
        % Sampler
        thisR.sampler.pixelsamples.value = val;
        thisR.sampler.pixelsamples.type = 'integer';

    case{'cropwindow', 'crop window'}
        thisR.film.cropwindow.value = [val(1) val(2) val(3) val(4)];
        thisR.film.cropwindow.type = 'float';

    % SUMO parameters stored in recipe metadata
    case {'trafficflowdensity'}
        thisR.metadata.sumo.trafficflowdensity = val;

    case {'traffictimestamp'}
        thisR.metadata.sumo.timestamp = val;

    otherwise
        error('Unknown parameter %s\n', param);
end

end