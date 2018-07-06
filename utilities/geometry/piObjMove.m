
function obj = piObjRotate(obj)
obj.concattransform.y 
end

function obj = piObjTranslate(obj)
obj.concattranform.t
end


function piAddSkybox(scene,varargin)
% Choose a skybox, or random skybox
parser = inputParser();

end

function pibboxox(scene)
% input: scene mesh file
%        mesh.txt
% getBndBox

 instanceIDs = unique(meshImage);% Find index of labeled object
 objectId = 1;
 for i=1:length(instanceIDs)
   indicator = (meshImage == instanceIDs(2));
   if sum(indicator(:)) == 0
       continue;
   end
   
   xSpread = sum(indicator);
   xIndices = find(xSpread > 0);
   
   ySpread = sum(indicator,2);
   yIndices = find(ySpread > 0);
   
   objects{objectId}.name        = 'car';
   objects{objectId}.bndbox.xmin = min(xIndices);
   objects{objectId}.bndbox.xmax = max(xIndices);
   objects{objectId}.bndbox.ymin = min(yIndices);
   objects{objectId}.bndbox.ymax = max(yIndices);
 end
 detections = objects;
 figure;
 imshow(oiGet(scene,'rgb image'),'Border','tight');
 for j=1:length(detections)
     pos = [detections{j}.bndbox.xmin detections{j}.bndbox.ymin ...
         detections{j}.bndbox.xmax-detections{j}.bndbox.xmin ...
         detections{j}.bndbox.ymax-detections{j}.bndbox.ymin];
     rectangle('Position',pos);
     
 end
 drawnow;
end