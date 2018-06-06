pro badpoint2

  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]

  gro=intarr(6)
  gro2=intarr(4)

  for picn=0,num-1 do begin
    filenam=filename[picn]
    namelen=strlen(filenam)
    filen1=strmid(filenam,0,47)
    filenuse=strjoin([filen1,'bp'])
    filen=strjoin([filenuse,'.tif'])
    
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    f=dblarr(nb,ns,nl)
    f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    f2=f

    for i=0,nl-1,1 do begin
      for j=0,ns-1,1 do begin
        if (i ne 0)&&(j ne 0)&&(i ne nl-1)&&(j ne ns-1)&&(f[0,j,i]gt 4400)then begin;不能这么大，会残留坏点
          gro=[f[0,j-1,i-1],f[0,j,i-1],f[0,j+1,i-1],f[0,j-1,i+1],f[0,j,i+1],f[0,j+1,i+1],f[0,j-1,i],f[0,j+1,i]]
          ave=mean(gro)
          if (f[0,j,i]gt ave*1.06)||(f[0,j,i]lt ave*0.95) then begin;30:1.065  25:1.065  35030:1.085 lowerborder=0.94;1.05需要. 大图用1.15和0.9
            f2[0,j,i]=0
          endif

        endif

      endfor
    endfor

    for i=0,nl-1,1 do begin
      for j=0,ns-1,1 do begin
        if (i ne 0)&&(j ne 0)&&(i ne nl-1)&&(j ne ns-1)then begin
          if (f2[0,j,i]eq 0) then begin
            gro=[f2[0,j-1,i],f2[0,j,i-1],f2[0,j+1,i],f2[0,j,i+1]]
            if (f2[0,j-1,i]ne 0 && f2[0,j,i-1]ne 0 &&f2[0,j+1,i]ne 0 &&f2[0,j,i+1]ne 0) then begin
            ave=mean(gro)
            endif else if ((f2[0,j-1,i]eq 0 && f2[0,j,i-1]ne 0 &&f2[0,j+1,i]ne 0 &&f2[0,j,i+1]ne 0)||(f2[0,j-1,i]ne 0 && f2[0,j,i-1]eq 0 &&f2[0,j+1,i]ne 0 &&f2[0,j,i+1]ne 0)||(f2[0,j-1,i]ne 0 && f2[0,j,i-1]ne 0 &&f2[0,j+1,i]eq 0 &&f2[0,j,i+1]ne 0)||(f2[0,j-1,i]ne 0 && f2[0,j,i-1]ne 0 &&f2[0,j+1,i]ne 0 &&f2[0,j,i+1]eq 0)) then begin
              ave=(f2[0,j-1,i]+f2[0,j,i-1]+f2[0,j+1,i]+f2[0,j,i+1])/3
            endif else begin
              ave=(f2[0,j-1,i]+f2[0,j,i-1]+f2[0,j+1,i]+f2[0,j,i+1])/2
            endelse
            
            ;if (f[0,j,i]gt ave*1.17)||(f[0,j,i]lt ave*0.83) then begin
              f2[0,j,i]=ave
            ;endif
            
          endif
        endif

      endfor
    endfor
    ;ENVI_ENTER_DATA, f, r_fid = rFid

    ENVI_WRITE_ENVI_FILE,f2,out_name=filen,NB=nb, NL=nl, NS=ns
    ;write_tiff, filen, f
  endfor
end