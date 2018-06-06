pro badlineremove
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]



  for picn=0,num-1 do begin
    filenam=filename[picn]
    namelen=strlen(filenam)
    filen1=strmid(filenam,0,47)
    filenuse=strjoin([filenam,'bl'])
    filen=strjoin([filenuse,'.img'])

    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    f=dblarr(nb,ns,nl)
    f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    
   ; f2=dblarr(ns)
    
   ; for i=0,nl-1,1 do begin
   ;   f2[i]=mean(f[0,i,*])
   ; endfor
   ; f3=f2
   ; for i=1,nl-2,1 do begin
   ;   if (abs(f2[i]-(f2[i-1]+f2[i+1])/2) gt (f2[i-1]+f2[i+1])/20) then begin
   ;     f3[i]=0
   ;   endif
   ; endfor
    
   ; for i=1,nl-3,1 do begin
      for j=0,ns-2,1 do begin
       ; if ((f3[i]eq 0) &&(f3[i+1]eq 0))then begin
        offset=3573
          f[0,5412-offset,j]=0.75*f[0,5411-offset,j]+0.25*f[0,5414-offset,j]
          f[0,5413-offset,j]=0.25*f[0,5411-offset,j]+0.75*f[0,5414-offset,j]
       ; endif

      endfor
   ; endfor


    ENVI_WRITE_ENVI_FILE,f,out_name=filen,NB=nb, NL=nl, NS=ns

  endfor

end