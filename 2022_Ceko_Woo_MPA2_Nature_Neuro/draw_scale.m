function draw_scale(scale)

% DRAWRING SCALES
% draw_scale(scale)

global theWindow W H; % window property
global white red orange bgcolor; % color
global t r; % pressure device udp channel
global window_rect prompt_ex lb rb scale_W anchor_y anchor_y2 anchor promptW promptH; % rating scale

switch scale
    case 'line'
        xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_int'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','0 kg/cm^2',lb-60,anchor_y,255);
        Screen(theWindow,'DrawText',' ',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','10 kg/cm^2',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText',' ',rb-50,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_avoidance'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-35,anchor_y2,255);
        Screen(theWindow,'DrawText','Most',rb,anchor_y,255);
        Screen(theWindow,'DrawText',' ',rb,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_unpleasant'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'lms'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-100,anchor_y-20,255);
        Screen(theWindow,'DrawText','at all',lb-100,anchor_y2-20,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
        for i = 1:5
            Screen('DrawLine', theWindow, 0, anchor(i), H/2+scale_W, anchor(i), H/2, 2);
        end
        Screen(theWindow,'DrawText','barely',anchor(1)-30,anchor_y+scale_W/2.5,255);
        Screen(theWindow,'DrawText','detectable',anchor(1)-30,anchor_y2+scale_W/2.5,255);
        Screen(theWindow,'DrawText','weak',anchor(2)-10,anchor_y,255);
        Screen(theWindow,'DrawText','moderate',anchor(3),anchor_y,255);
        Screen(theWindow,'DrawText','strong',anchor(4),anchor_y,255);
        Screen(theWindow,'DrawText','very',anchor(5),anchor_y,255);
        Screen(theWindow,'DrawText','strong',anchor(5),anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'cont_int'
        xy = [lb H/6+scale_W; rb H/6+scale_W; rb H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        Screen(theWindow,'DrawText','Not',lb-50,H/6+10+scale_W,255);
        Screen(theWindow,'DrawText','at all',lb-50,H/6+10+scale_W+25,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,H/6+10+scale_W,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,H/6+10+scale_W+25,255);
        % Screen('Flip', theWindow);
    case 'cont_avoidance'
        xy = [lb H/6+scale_W; rb H/6+scale_W; rb H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        Screen(theWindow,'DrawText','Not',lb-35,H/6+10+scale_W,255);
        Screen(theWindow,'DrawText','at all',lb-35,H/6+10+scale_W+25,255);
        Screen(theWindow,'DrawText','Most',rb,H/6+10+scale_W,255);
        Screen(theWindow,'DrawText',' ',rb,H/6+10+scale_W+25,255);
%     case 'overall_int'
%         xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
%         Screen(theWindow, 'FillPoly', 255, xy);
%         Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
%         Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
%         Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
%         Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_aversive_ornot'
        lb2 = W/3;
        rb2 = (W*2)/3;
        lb3 = lb2+((rb2-lb2).*0.4);
        rb3 = rb2-((rb2-lb2).*0.4);
        xy = [lb2 lb2 lb2 lb3 lb3 lb3;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb3 rb3 rb3;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        Screen(theWindow,'DrawText','YES',lb2+50,H/2-scale_W/2,255);
        Screen(theWindow,'DrawText','NO',rb3+50,H/2-scale_W/2,255);
    case 'overall_pain_ornot'
        lb2 = W/3;
        rb2 = (W*2)/3;
        lb3 = lb2+((rb2-lb2).*0.4);
        rb3 = rb2-((rb2-lb2).*0.4);
        xy = [lb2 lb2 lb2 lb3 lb3 lb3;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb3 rb3 rb3;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        Screen(theWindow,'DrawText','YES',lb2+50,H/2-scale_W/2,255);
        Screen(theWindow,'DrawText','NO',rb3+50,H/2-scale_W/2,255);
    case 'overall_boredness'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Not bored',lb-40,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-40,anchor_y2,255);
        Screen(theWindow,'DrawText','Extremely',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','Bored',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
	case 'overall_alertness'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Extremely',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','sleepy',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Extremely',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','alert',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_relaxed'
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Least',lb-40,anchor_y,255);
        Screen(theWindow,'DrawText','relaxed',lb-40,anchor_y2,255);
        Screen(theWindow,'DrawText','Most',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','relaxed',rb-35,anchor_y2,255);
    case 'overall_attention'
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Not',lb-40,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-40,anchor_y2,255);
        Screen(theWindow,'DrawText','Best',rb-35,anchor_y,255);
	case 'overall_resting_positive'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
	case 'overall_resting_negative'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
	case 'overall_resting_myself'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_resting_others'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_resting_imagery'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_resting_present'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_resting_past'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_resting_future'
        %xy = [lb lb lb rb rb rb; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        % added middle line
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Strongly',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','agree',lb-35,anchor_y2,255);
        
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        
        Screen(theWindow,'DrawText','Strongly',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText','disagree',rb-35,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_resting_bitter_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_resting_bitter_unp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_resting_capsai_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_resting_capsai_unp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_thermal_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_thermal_unp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_pressure_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_pressure_unp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_negvis_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_negvis_unp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_negaud_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_negaud_unp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_posvis_int'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_posvis_ple'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Most',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);
    case 'overall_comfortness'
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Not',lb-40,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-40,anchor_y2,255);
        Screen(theWindow,'DrawText','Most',rb-35,anchor_y,255);
        Screen(theWindow,'DrawText',' ',rb-35,anchor_y2,255);
    case 'overall_mood'
        xy = [lb lb lb (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 (lb+rb)/2 rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','Negative',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','Neutral',(lb+rb)/2-35,anchor_y,255);
        Screen(theWindow,'DrawText','Positive',rb-35,anchor_y,255);
    case 'cont_avoidance_exp'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', orange, xy);
        Screen(theWindow,'DrawText','Not',lb-35,H/2+10+scale_W,255);
        Screen(theWindow,'DrawText','at all',lb-35,H/2+10+scale_W+25,255);
        Screen(theWindow,'DrawText','Most',rb,H/2+10+scale_W,255);
        Screen(theWindow,'DrawText',' ',rb,H/2+10+scale_W+25,255);

end

end     