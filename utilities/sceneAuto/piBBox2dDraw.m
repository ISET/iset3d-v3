function annotationFig=piBBox2dDraw(ieObject)
% ieObject is a vcimage
annotationFig = figure;
pngFigure = ipGet(ieObject,'data srgb');
ipWindow
% pngFigure = xyz2rgb(pngFigure,'ColorSpace','adobe-rgb-1998');
imshow(pngFigure);

if ~isempty(ieObject.metadata.bbox2d)
    fds = fieldnames(ieObject.metadata.bbox2d);
    for kk = 1:length(fds)
        detections = ieObject.metadata.bbox2d.(fds{kk});
        switch fds{kk}
            case 'car'
                r = 0.1; g= 0.8; b = 0.1;
            case 'truck'
                r = 0.1; g= 0.5; b = 0.1;
            case 'pedestrian'
                r = 0.8; g= 0.1; b = 0.1;
            case 'bicycle'
                r = 0.6; g= 0.3; b = 0.5;
            case 'rider'
                r = 0.7; g= 0.3; b = 0.1;
            case 'motor'
                r = 0.5; g= 0.7; b = 0.1;
            case 'bus'
                r = 0.5; g= 0.3; b = 0.7;
        end
%         r = rand; g = rand; b = rand;
%         if r< 0.2 && g < 0.2 && b< 0.2
%             r = 0.5; g = rand; b = rand;
%         end
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
