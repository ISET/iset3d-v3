function annotationFig=piBBox2dDraw(ieObject)
% ieObject is an Optical Image
% later it should be an oi
annotationFig = figure;
pngFigure = oiGet(ieObject,'rgb image');
imshow(pngFigure);

if ~isempty(ieObject.metadata.bbox2d)
    fds = fieldnames(ieObject.metadata.bbox2d);
    for kk = 1:length(fds)
        detections = ieObject.metadata.bbox2d.(fds{kk});
        r = rand; g = rand; b = rand;
        if r< 0.2 && g < 0.2 && b< 0.2
            r = 0.5; g = rand; b = rand;
        end
        for jj=1:length(detections)
            if ~detections{jj}.ignore
                pos = [detections{jj}.bbox2d.xmin detections{jj}.bbox2d.ymin ...
                    detections{jj}.bbox2d.xmax-detections{jj}.bbox2d.xmin ...
                    detections{jj}.bbox2d.ymax-detections{jj}.bbox2d.ymin];
                
                rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',1);
                %         t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,num2str(jj));
                tex=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,fds{kk});
                tex.Color = [0 0 0];
                tex.BackgroundColor = [r g b];
                tex.FontSize = 5;
            end
        end
        
    end
    drawnow;
else
    disp('No object in the scene');
end
