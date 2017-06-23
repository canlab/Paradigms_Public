%Generador logfile sons

tInici=30000;
deltaT=400; %2,5 Hz

%Definicio

fid=fopen('plantillaAudioBIRN.txt','w')

for i=1:15
    fprintf(fid,'sound {\n');
    fprintf(fid,['wavefile { filename = "to' num2str(i) '.wav"; };\n']);
    fprintf(fid,['} so' num2str(i) ';\n']);
end

%definir onsets

fprintf(fid,'\npart dins del trial\n\n');


for i=1:5 % 5 cicles complerts (30s)
    for ii=1:15 % 15 sons diferents
         fprintf(fid,['sound so' num2str(ii) ';\n']);
         fprintf(fid,['time = ' num2str(tInici+6000*(i-1)+400*(ii-1)) ';\n']);
         fprintf(fid,['code="so ' num2str(ii) '";\n']);
    end
end


fclose(fid)