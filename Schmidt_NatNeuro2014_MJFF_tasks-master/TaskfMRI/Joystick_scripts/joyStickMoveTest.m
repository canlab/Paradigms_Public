% function joyStickMoveTest(gamepadIndex)
gamepadIndex=1;
[Window,Rect] = initializeScreen;
thePoints=[];
idx=0;
lastTrigger=0; % will get reset when trigger pulled

bgColor=[0 0 0];

Screen('FillRect', Window,bgColor,Rect);
starttime=Screen('Flip',Window);
endtime=starttime+10;
%motionParam=5;
motionThresh=0.10; % minimum argument coming from the joystick (allows it to remain stationary)

currentX=round(Rect(3)/2);
currentY=round(Rect(4)/2);

SetMouse(currentX,currentY,Window);

while (GetSecs<=endtime)
    outputCoords=getGamePadCoords(gamepadIndex);
    
    if abs(outputCoords(1))>motionThresh && round(currentX+outputCoords(1)*10)>=0 && round(currentX+outputCoords(1)*10)<=Rect(3)
        currentX=round(currentX+outputCoords(1)*10);
    end
    
    if abs(outputCoords(2))>motionThresh && round(currentY+outputCoords(2)*10)>=0 && round(currentY+outputCoords(2)*10)<=Rect(4)
        currentY=round(currentY+outputCoords(2)*10);
    end
    
    SetMouse(currentX,currentY,Window);
    x=currentX;
    y=currentY;
    [x,y]=GetMouse(Window);
    ShowCursor('CrossHair',Window);
    waitSecs(0.01);
    %get positions
    idx=idx+1;
    thePoints(idx,:)=[x, y]
    
end
HideCursor
Screen('TextSize',Window,72);
DrawFormattedText(Window,'END','center','center',255);
Screen('Flip',Window);
waitSecs(1)
clear screen

figure 
plot(thePoints(:,1),thePoints(:,2));
