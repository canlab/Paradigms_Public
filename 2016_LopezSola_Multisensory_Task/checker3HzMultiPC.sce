pcl_file = "checkergs.pcl"; 
default_deltat = 167;

begin;

picture {
   
   background_color = 0,0,0;
   
   } default;

box { height = 1; width = 1; color = 255,255,255; } box1;
box { height = 1; width = 1; color = 255,255,255; } box2;

picture {} pic1;
picture {} pic2; 

trial {
   trial_duration = 60000; 
   picture default;
   time=0;
   code = "repos";       
   picture pic1;
   time = 30000;
   code = "inici bloc";    
   picture pic2;
   LOOP $i 100;
   picture pic1;
   code = 1;
   picture pic2;
   code = 2;
   ENDLOOP;
}trial1;
trial {
   trial_duration= 10000;
   picture default;
   time=0;
}trial2;

