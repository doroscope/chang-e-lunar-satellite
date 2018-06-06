pro removebackgroundspecial
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]

  ;for picn=0,num-1 do begin
    filenam=filename[0]
    filenam2=filename[1]
    ;namelen=strlen(filenam)
    ;filen1=strmid(filenam,0,60)
    ;filenuse=strjoin([filen1,'removebg2'])
    filen=strjoin([filenam2,'-DC'])
    filebg=strjoin([filenam2,'bg.txt'])

    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    f=intarr(nb,ns,nl)
    f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    f2=intarr(nl)
    sample=1008-960+1
    f3=intarr(sample)
    envi_open_file,filenam2,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb2,ns = ns2, nl = nl2
    fc=intarr(nb2,ns2,nl2)
    fc[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    fc2=fc

    for j=0,nl-1,1 do begin
      count=0
      for i=959,1007,1 do begin
        f3[i-959]=f[0,i,j]
        if (f[0,i,j]gt 1290 || f[0,i,j]lt 250) then begin ;去掉下阈值以匹配最下面行，并去除夜空中坏点。写个说明文件。
          f3[i-959]=0
          count=count+1
        endif

      endfor
      f2[j]=mean(f3)*sample/(sample-count)
    endfor

    for j2=0,nl2-1,1 do begin
      for i2=0,ns2-1,1 do begin
        fc2[0,i2,j2]=((fc[0,i2,j2]-f2[j2+98]));*0.0265-1.78
        if (fc[0,i2,j2] eq 4400) then begin
          fc2[0,i2,j2]=0
        endif
      endfor
    endfor
    ;ENVI_ENTER_DATA, f, r_fid = rFid

    ENVI_WRITE_ENVI_FILE,fc2,out_name=filen,NB=nb2, NL=nl2, NS=ns2
    openw,lun1,filebg,/get_lun
    printf,lun1,FORMAT='(1I12)',f2[98:857]
    close,lun1

    ;write_tiff, filen, f
  ;endfor

end