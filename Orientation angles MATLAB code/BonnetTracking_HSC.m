clear all

% Load Video
video = "0deg_5cm_4hz";
name = "0deg_5cm_4hz";
videoname = "0deg\0deg\" + video + "\" + video + ".avi";
vid = VideoReader(videoname);
frames = vid.NumFrames;

%% Test Threshhold

vidFrame = readFrame(vid);
bw = rgb2gray(vidFrame);
bin = imbinarize(bw);
%out = imrotate(bin,-90);
imshow(bin)

%% Choose Center Point
objectFrame = readFrame(vid);
%show = imrotate(objectFrame,-90);
figure; imshow(objectFrame)
title('Pick center point and close frame')
[vx, vy] = ginput(1);
center = [vx,vy];

%% Play video and track Bonnet Angle

%Get initial angle (only need for unwrapping to 2pi)
%startFrame = readFrame(vid);
%startFrame2 = imrotate(startFrame,-90);
%bw = rgb2gray(startFrame2);
%bin = imbinarize(bw);
    
    
%CC = bwconncomp(bin);

%stats = regionprops('table',CC,'Area');
%[~,idx] = sort(stats.Area,'descend');
%bin2 = cc2bw(CC,ObjectsToKeep=idx(1));

%or = regionprops(bin2,'centroid','Orientation');

i=1;

storedangle = zeros(frames,1);
%storedangle(1) = or.Orientation;

%Create Videowriter object
v = VideoWriter('./processed/.5.cm_6Hz_250FPS.avi','Motion JPEG AVI');
v.FrameRate = 30;
open(v)

while hasFrame(vid)   
    
    vidFrame = readFrame(vid);
    %vidFrame2 = imrotate(vidFrame,-90);
    bw = rgb2gray(vidFrame);
    bin = imbinarize(bw);
    
    
    CC = bwconncomp(bin);

    stats = regionprops('table',CC,'Area');
    [~,idx] = sort(stats.Area,'descend');
    bin2 = cc2bw(CC,ObjectsToKeep=idx(1));

    or = regionprops(bin2,'centroid','Orientation');
    
    angle = or.Orientation;

    % unravel data to 2pi
    %jump = or.Orientation - storedangle(i-1);
    
    %if jump > 90 && jump < 270
        %angle = or.Orientation - 180;
    %elseif jump < -90 && jump > -270
        %angle = or.Orientation + 180;
    %else
        %angle = or.Orientation;
    %end

    %make everything positive 0 to pi
    if angle < 0
        angle = angle+180;
    end

    storedangle(i) = angle;

    p1 = center;
    drawnangle = deg2rad(-1*angle);
    l = 250;
    p2 = p1 + [l*cos(drawnangle),l*sin(drawnangle)];
    p3 = p1 - [l*cos(drawnangle),l*sin(drawnangle)];

    out = insertShape(vidFrame,'line',[p2,p3],'LineWidth',3,'ShapeColor','red');
    
    %Save Video
    writeVideo(v,out);

    imshow(out); 
    
    i=i+1;
    
end

close(v)

%% Plot
FrameRate = 30;
y = (storedangle-180)*(-1)*pi/180;
x = [1:frames]'./FrameRate;

plot(x,y,".",'MarkerSize',10)
set(gcf,'color','w')
set(gca,'fontsize',16)
ylabel('Bonnet Angle (°)')
xlabel('Time (s)') 
