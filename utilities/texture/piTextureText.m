function val = piTextureText(texture, thisR, varargin)
% Compose text for textures
%
% Input:
%   texture - texture struct
%
% Outputs:
%   val     - text
%
% ZLY, 2021
% 
% See also

%% Parse input
p = inputParser;
p.addRequired('texture', @isstruct);
p.addRequired('thisR', @(x)(isa(x,'recipe')));
p.parse(texture, thisR, varargin{:});

%% Concatenate string
% Name
if ~strcmp(texture.name, '')
    valName = sprintf('Texture "%s" ', texture.name);
else
    error('Bad texture structure')
end

% format
formTxt = sprintf(' "%s"', texture.format);
val = strcat(valName, formTxt);

% type
tyTxt = sprintf(' "%s"', texture.type);
val = strcat(val, tyTxt);

%% For each field that is not empty, concatenate it to the text line
textureParams = fieldnames(texture);

for ii=1:numel(textureParams)
    if ~isequal(textureParams{ii}, 'name') && ...
            ~isequal(textureParams{ii}, 'type') && ...
            ~isequal(textureParams{ii}, 'format') && ...
            ~isempty(texture.(textureParams{ii}).value)
         thisType = texture.(textureParams{ii}).type;
         thisVal = texture.(textureParams{ii}).value;
         
         if ischar(thisVal)
             thisText = sprintf(' "%s %s" "%s" ',...
                 thisType, textureParams{ii}, thisVal);
         elseif isnumeric(thisVal)
            if isinteger(thisType)
                thisText = sprintf(' "%s %s" [%s] ',...
                     thisType, textureParams{ii}, num2str(thisVal, '%d'));
            else
                thisText = sprintf(' "%s %s" [%s] ',...
                     thisType, textureParams{ii}, num2str(thisVal, '%.4f '));
            end
         end

         val = strcat(val, thisText);
         
         if isequal(textureParams{ii}, 'filename')
            if ~exist(fullfile(thisR.get('output dir'),thisVal),'file')
                imgFile = which(thisVal);
                if isempty(imgFile)||isequal(imgFile,'')
                    warning('Texture %s not found!', thisVal);
                else
                    copyfile(imgFile,thisR.get('output dir'));
                end
            end
         end
    end
end
