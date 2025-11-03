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
%         xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
%         Screen(theWindow, 'FillPoly', 255, xy);
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawText','No Pain',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','Most Pain Imaginable',rb,anchor_y,255);
        Screen(theWindow,'DrawText',' ',rb,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_expect'
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 1);
        Screen(theWindow,'DrawText','No Pain',lb-60,anchor_y,1);
        Screen(theWindow,'DrawText','Most Pain Imaginable',rb-50,anchor_y,1);
        Screen(theWindow,'DrawText',' ',rb-50,anchor_y2,255);
    case 'overall_avoidance'
        xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-35,anchor_y,255);
        Screen(theWindow,'DrawText','at all',lb-35,anchor_y2,255);
        Screen(theWindow,'DrawText','Most',rb,anchor_y,255);
        Screen(theWindow,'DrawText',' ',rb,anchor_y2,255);
        % Screen('Flip', theWindow);
    case 'overall_unpleasant'
        xy = [lb lb lb rb rb rb; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        
        %xy = [lb H/2+scale_W; rb H/2+scale_W; rb H/2];
        %Screen(theWindow, 'FillPoly', 255, xy);
        Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        Screen(theWindow,'DrawText','At All',lb-50,anchor_y2,255);
        Screen(theWindow,'DrawText','Worst Pain',rb-50,anchor_y,255);
        Screen(theWindow,'DrawText','Imaginable',rb-50,anchor_y2,255);
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

end

end     