pro average_ce3
  COMPILE_OPT idl2
  ENVI,/RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT
  
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  
  number=size(filename)
  num=number[3]
  for picn=0,num-1 do begin
    ce3filename=filename[picn]
    filepos=strpos(ce3filename,'.2B')
    filehead=strmid(ce3filename,0,filepos)
    outfile=strjoin([filehead,'.txt'])
    ;ce3filename = "E:\Wu_ce3\CE3_BMYK_VNIS-CC_SCI_N_20131223023539_20131223023539_0005_A.2B"
    ;outfile="E:\Wu_ce3\CE3_BMYK_VNIS-CC_SCI_N_20131223023539_20131223023539_0005_A.2B.txt"
    x0 =  98.4847 ; 96
    y0 = 128.5 ; 128
    area = 53.8 ; 53.5
    tmparr = fltarr(256,256)
    mask = intarr(256,256)
    for ix=1,256 do begin
      for iy=1,256 do begin
        tmparr[ix-1,iy-1] =sqrt((ix-x0)^2+(iy-y0)^2)
      endfor
    endfor
    mask[where(tmparr le area)] = 1
    tmp = where(mask eq 1,cnt)
    envi_open_file,ce3filename, R_FID=fid
    ENVI_FILE_QUERY, fid, DIMS=dims,ns=ns,nl=nl,nb=nb
    outspectra = fltarr(nb)
    vnisdata = fltarr(ns,nl,nb)
    for i = 0,nb-1 do begin
      vnisdata[*,*,i] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
      outspectra[i] = total(mask * vnisdata[*,*,i])/cnt
    endfor
  
   ; print,outspectra
    
    openw,lun,outfile,/GET_LUN
    for i=0,nb-1 do begin
      printf,lun,outspectra[i]
    endfor
    
    close,lun
  endfor
  ;ENVI_BATCH_EXIT
end
