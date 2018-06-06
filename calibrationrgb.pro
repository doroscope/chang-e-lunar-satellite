pro calibrationrgb

  cd,'e:\ce3_pcam_2b\'
  filename=dialog_pickfile(filter='*.2B',/read,/multiple)
  number=size(filename)
  num=number[3]

  data=dblarr(9,2352,1728)

  for picn=0,num-1 do begin

    filenam=filename[picn]
    namelen=strlen(filenam)
    filen1=strmid(filenam,15,64)
    filenuse=strjoin([filen1,'2B----angle.txt'])
    filenr=strjoin([filen1,'r'])
    fileng=strjoin([filen1,'g'])
    filenb=strjoin([filen1,'b'])
    ;filensta=strjoin([filen1,'sta'])

    openr,lun2,filenuse,/get_lun

    readf,lun2,data
    free_lun,lun2

    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    ; nbandbegin=1
    ; nbands=nb-nbandbegin
    f=dblarr(nb,ns,nl)


    f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)

    ;help,f
    ;print,f[0,1,2]
    OpenR, lun, filenam, /Get_Lun
    header =bytArr(3000)
    ReadU, lun, header
    header=string(header)
    ;print,header
    str2='ACali'
    acapos=strpos(header,str2)
    acali=strmid(header,acapos+44,8)
    acali=float(acali)
    ;print,acali

    is=dblarr(2,ns,nl)
    is[0,*,*]=f[0,*,*]
    is[1,*,*]=data[8,*,*]
    ;print,is[0,2,3]
    ;help,is
    for i=0,nl-1,2 do begin
      for j=0,ns-1,2 do begin
        is[0,j,i]=is[0,j,i]*!pi/(acali*5.9365e5)/1.990384/cos(data[7,j,i]*!pi/180)
      endfor
    endfor
    for i=0,nl-1,2 do begin
      for j=1,ns-1,2 do begin
        is[0,j,i]=is[0,j,i]*!pi/(acali*5.9796e5)/2.336897/cos(data[7,j,i]*!pi/180)
      endfor
    endfor
    for i=1,nl-1,2 do begin
      for j=0,ns-1,2 do begin
        is[0,j,i]=is[0,j,i]*!pi/(acali*5.8939e5)/2.336897/cos(data[7,j,i]*!pi/180)
      endfor
    endfor
    for i=1,nl-1,2 do begin
      for j=1,ns-1,2 do begin
        is[0,j,i]=is[0,j,i]*!pi/(acali*5.1837e5)/2.233547/cos(data[7,j,i]*!pi/180)
      endfor
    endfor

    ave=mean(is[0,*,*])
    pmin=min(is[1,*,*])-0.0001
    pmax=max(is[1,*,*])
    groupnum=ceil((pmax-pmin)/0.1)
    r=dblarr(groupnum,3,20000)
    g=dblarr(groupnum,3,40000)
    b=dblarr(groupnum,3,20000)
    ;statistics=dblarr(groupnum,3,80000)
    for i=0,nl-1,1 do begin
      for j=0,ns-1,1 do begin
        if (abs(is[1,j,i]-0) lt 0.0001) then begin
          is[0,j,i]=0
        endif
        if (abs(is[0,j,i]-0) lt 0.002) then begin
          is[0,j,i]=0
        endif
        if (abs(is[0,j,i]) lt ave*0.2) then begin
          is[0,j,i]=0
        endif
        if (abs(is[0,j,i]-ave) ge (ave*0.55)) then begin
          is[0,j,i]=0
        endif
        if (abs(is[0,j,i]-0) gt 0.0001) then begin
          if (i mod 2 eq 0)&&(j mod 2 eq 0) then begin
            pointnum=ceil((is[1,j,i]-pmin)/0.1)
            count=r[pointnum-1,2,0]
            r[pointnum-1,0,count]=is[0,j,i]
            r[pointnum-1,1,count]=is[1,j,i]
            r[pointnum-1,2,0]=r[pointnum-1,2,0]+1
          endif
          if (i mod 2 eq 1)&&(j mod 2 eq 1) then begin
            pointnum=ceil((is[1,j,i]-pmin)/0.1)
            count=b[pointnum-1,2,0]
            b[pointnum-1,0,count]=is[0,j,i]
            b[pointnum-1,1,count]=is[1,j,i]
            b[pointnum-1,2,0]=b[pointnum-1,2,0]+1
          endif
          if ((i mod 2 eq 0)&&(j mod 2 eq 1)) || ((i mod 2 eq 1)&&(j mod 2 eq 0)) then begin
            pointnum=ceil((is[1,j,i]-pmin)/0.1)
            count=g[pointnum-1,2,0]
            g[pointnum-1,0,count]=is[0,j,i]
            g[pointnum-1,1,count]=is[1,j,i]
            g[pointnum-1,2,0]=g[pointnum-1,2,0]+1
          endif
        endif
      endfor
    endfor

    star=dblarr(2,groupnum)
    stag=dblarr(2,groupnum)
    stab=dblarr(2,groupnum)
    for group=0,groupnum-1 do begin
      star[0,group]=total(r[group,0,*])/r[group,2,0]
      star[1,group]=total(r[group,1,*])/r[group,2,0]
      stag[0,group]=total(g[group,0,*])/g[group,2,0]
      stag[1,group]=total(g[group,1,*])/g[group,2,0]
      stab[0,group]=total(b[group,0,*])/b[group,2,0]
      stab[1,group]=total(b[group,1,*])/b[group,2,0]
    endfor


    


  ;  openw,lun3,filenresult,/get_lun
  ;  printf,lun3,is
  ;  print,filenresult
  ;  free_lun,lun3
    openw,lun4,filenr,/get_lun
    printf,lun4,star
    print,filenr
    free_lun,lun4
    openw,lun4,fileng,/get_lun
    printf,lun4,stag
    print,fileng
    free_lun,lun4
    openw,lun4,filenb,/get_lun
    printf,lun4,stab
    print,filenb
    free_lun,lun4
    delvar,is
    delvar,r,g,b
  endfor

end