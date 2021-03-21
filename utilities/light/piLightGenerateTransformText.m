function txt = piLightGenerateTransformText(lght)
% Check translation
txt = {};

[~, rotationTxt] = piLightGet(lght, 'rotation val', 'pbrt text', true);
[~, translationTxt] = piLightGet(lght, 'translation val', 'pbrt text', true);
[~, ctformTxt] = piLightGet(lght, 'ctform val', 'pbrt text', true);
[~, sclTxt] = piLightGet(lght, 'scale val', 'pbrt text', true);

if ~isempty(translationTxt)
    txt = [txt translationTxt];
end

if ~isempty(rotationTxt)
    txt = [txt rotationTxt];
elseif ~isempty(ctformTxt)
    txt = [txt ctformTxt];
end

if ~isempty(sclTxt)
    txt = [txt sclTxt];
end

%% Old version
% This part has been moved to piLightGet.
%{
if ~isempty(translation)
    for ii=1:numel(translation)
        txt{end + 1} = sprintf('Translate %.3f %.3f %.3f',...
                            translation{ii}(1), translation{ii}(2),...
                            translation{ii}(3));
    end
end


if ~isempty(rotation)
    % Copying from Zhenyi's code, Which does not account for multiple
    % rotations I think
    %{
    % might remove this;
    if iscell(rotate)
        rotate = rotate{1};
    end
    %}
    for ii=1:numel(rotation)
        curRot = rotation{ii};
        rot_size = size(curRot);
        if rot_size(1)>rot_size(2)
            curRot = curRot';
        end
        % Check rotate along wich axis
        for rr = 1:3
            thisRotate = curRot(rr,:);
            degree = thisRotate(1);
            if thisRotate(2)==1
                x_degree = degree;
            elseif thisRotate(3)==1
                y_degree = degree;
            elseif thisRotate(4)==1
                z_degree = degree;
            end
        end
        if exist('z_degree','var')
            txt{end+1} = sprintf('Rotate %.3f 0 0 1', z_degree);
        end
        if exist('y_degree', 'var')
            txt{end+1} = sprintf('Rotate %.3f 0 1 0', y_degree);
        end
        if exist('x_degree', 'var')
            txt{end+1} = sprintf('Rotate %.3f 1 0 0', x_degree);
        end
    end
elseif ~isempty(ctform)
    txt{end + 1} = sprintf('ConcatTransform [%.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f]', ctform(:));
end

if ~isempty(scl)
    txt{end + 1} = sprintf('Scale %.3f %.3f %.3f', scl(1), scl(2), scl(3));
end
%}
end