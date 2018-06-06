pro removebackground
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]

  for picn=0,num-1 do begin
    filenam=filename[picn]
    namelen=strlen(filenam)
    filen1=strmid(filenam,0,60)
    filenuse=strjoin([filen1,'removebg2'])
    filen=strjoin([filenuse,'.img'])
    filebg=strjoin([filenuse,'.txt'])

    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    f=dblarr(nb,ns,nl)
    f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    f2=intarr(nl)
    sample=1008-960+1
    f3=intarr(sample)

    for j=0,nl-1,1 do begin
      count=0
      for i=959,1007,1 do begin
        f3[i-959]=f[0,i,j]
        if (f[0,i,j]gt 1500 || f[0,i,j]lt 0) then begin ;去掉下阈值以匹配最下面行，并去除夜空中坏点。写个说明文件。
          f3[i-959]=0
          count=count+1
        endif
      
      endfor
      f2[j]=mean(f3)*sample/(sample-count)
    endfor

    for i2=0,nl-1,1 do begin
      for j2=0,ns-1,1 do begin
        f[0,i2,j2]=fix((f[0,i2,j2]-f2[i2]))*0.0265-1.78

      endfor
    endfor
    ;ENVI_ENTER_DATA, f, r_fid = rFid

    ENVI_WRITE_ENVI_FILE,f,out_name=filen,NB=nb, NL=nl, NS=ns
    openw,lun1,filebg,/get_lun
    printf,lun1,FORMAT='(1I12)',f2
    close,lun1
    
    ;write_tiff, filen, f
  endfor

end