function objects = piBBoxExtract(thisR, objects, scene, meshImage, labelMap)
 % Read primitive ID from _mesh.txt
 % Add class information here: convert meshImage(instanceSeg) to A
 % classSeg.
 %
 % ZL, Vistasoft Team, 2018
 
 %%
 labelMap;
 instanceIDs = unique(meshImage);% Find index of labeled object
 instanceIDs = instanceIDs(instanceIDs > 0);
      
 instance = instanceIDSearch(thisR,instanceIDs);
 % Search ID in scene_mesh.txt, assign bndbox to the object.
 dd = 1; 
 for ii=1:length(instance)
     indicator = (meshImage == instance{ii}.index);
     if sum(indicator(:)) == 0
         continue;
     end
     
     xSpread = sum(indicator);
     xIndices = find(xSpread > 0);
     
     ySpread = sum(indicator,2);
     yIndices = find(ySpread > 0);
     for jj = 1:length(objects)
         if isequal(objects(jj).name, instance{ii}.name)
%              [~,name] = fileparts(thisR.outputFile);
%              tmp = strfind(name,'_');label = name(1:tmp-1);
%              detections(dd).label = label;
             detections(dd).index = jj;
         end
     end
     detections(dd).bndbox.xmin = min(xIndices);
     detections(dd).bndbox.xmax = max(xIndices);
     detections(dd).bndbox.ymin = min(yIndices);
     detections(dd).bndbox.ymax = max(yIndices);
     objects(detections(dd).index).bndbox.xmin = detections(dd).bndbox.xmin;
     objects(detections(dd).index).bndbox.xmax = detections(dd).bndbox.xmax;
     objects(detections(dd).index).bndbox.ymin = detections(dd).bndbox.ymin;
     objects(detections(dd).index).bndbox.ymax = detections(dd).bndbox.ymax;
%      objects(detections(dd).index).label       = detections(dd).label;
     dd = dd+1;
 end
 
 figure;
 imshow(oiGet(scene,'rgb image'),'Border','tight');
 for j=1:length(detections)
     pos = [detections(j).bndbox.xmin detections(j).bndbox.ymin ...
         detections(j).bndbox.xmax-detections(j).bndbox.xmin ...
         detections(j).bndbox.ymax-detections(j).bndbox.ymin];
     r = rand;
     g = rand;
     b = rand;
     rectangle('Position',pos,'EdgeColor',[r g b]);
 end
 drawnow;
 end
 function instance = instanceIDSearch(thisR, instanceIDs)
 [workdir, name] = fileparts(thisR.outputFile);
 fid_tmp = fopen(fullfile(workdir,'renderings',sprintf('%s_mesh_mesh.txt',name)));
 instanceIDlist = textscan(fid_tmp,'%s','Delimiter','\n');
 instanceIDlist = instanceIDlist{1};
 fclose(fid_tmp);dd = 1;
 for ii = 1:length(instanceIDlist)
     tmp = strfind(instanceIDlist{ii},' ');
     id{ii}.index = str2double(instanceIDlist{ii}(1:tmp-1));
     id{ii}.name = instanceIDlist{ii}(tmp+1:end); 
     % Search the corresponding name with the id found in meshImage
     
     for jj = 1:length(instanceIDs)    
     if instanceIDs(jj) == id{ii}.index
         instance{dd} = id{ii};
         dd = dd+1;
     end
     end
     fprintf('%d object instances found \n',dd-1);
 end
 end
 function SegmentationMap = instanceSeg(instanceIDs)
 
 end
 
function ClassMap = classSeg(instanceIDs,labelMap)
 
end
 
  
 
 
 