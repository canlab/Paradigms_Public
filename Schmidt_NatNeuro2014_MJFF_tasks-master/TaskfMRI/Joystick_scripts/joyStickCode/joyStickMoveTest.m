function joyStickMoveTest(gamepadIndex)

[Window,Rect] = initializeScreen;

TriggerButton=1;
% refractory period for button presses, otherwise it registers a BUNCH of
% clicks
triggerRefract=0.25;
lastTrigger=0; % will get reset when trigger pulled

bgColor=[0 0 0];

Screen('FillRect', Window,bgColor,Rect);
Screen('Flip',Window);

%motionParam=5;
motionThresh=0.005; % minimum argument coming from the joystick (allows it to remain stationary)

currentX=round(Rect(3)/2);
currentY=round(Rect(4)/2);


SetMouse(currentX,currentY,Window);

while true
    outputCoords=getGamePadCoords(gamepadIndex);
    
    if abs(outputCoords(1))>motionThresh && round(currentX+outputCoords(1)*10)>=0 && round(currentX+outputCoords(1)*10)<=Rect(3)
        currentX=round(currentX+outputCoords(1)*10);
    end
    
    if abs(outputCoords(2))>motionThresh && round(currentY+outputCoords(2)*10)>=0 && round(currentY+outputCoords(2)*10)<=Rect(4)
        currentY=round(currentY+outputCoords(2)*10);
    end
    
    SetMouse(currentX,currentY,Window);
    
    waitSecs(0.01);
    
    %check for button being down, change bg color if clicking
    if Gamepad('GetButton',gamepadIndex,TriggerButton) && getSecs-lastTrigger>triggerRefract
        bgColor=[round(rand*300) round(rand*300) round(rand*300)];
        Screen('FillRect', Window,bgColor,Rect);
        Screen('Flip',Window);
        lastTrigger=getSecs;
        
    end
    
end