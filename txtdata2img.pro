pro txtdata2img
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]
  
  data=dblarr(10,1024,1024)
  
  for picn=0,num-1 do begin
    filenam=filename[picn]
    ;namelen=strlen(filenam)
    ;filen1=strmid(filenam,0,60)
    filenuse=strjoin([filename,'geoinfo'])
    filen=strjoin([filenuse,'.img'])
    
    openr,lun,filenam,/get_lun
    readf,lun,data
    free_lun,lun
    
    data2=dblarr(1024,1024,8)
    for i=0,7 do begin
      for j=0,1023 do begin
        for k=0,1023 do begin
          data2(j,k,i)=data[i+2,j,k]
        endfor
      endfor
    endfor
    
    ENVI_WRITE_ENVI_FILE,data2,bnames=['longitude','latitude','satellite_azimuth','satellite_zenith','solar_azimuth','solar_zenith','phase_angle','solid_angle'],out_name=filen,NB=nb, NL=nl, NS=ns
    
    
  endfor

end