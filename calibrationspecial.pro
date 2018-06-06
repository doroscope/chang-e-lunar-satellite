pro calibrationspecial

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
    filenresult=strjoin([filen1,'ref'])
    filensta=strjoin([filen1,'sta'])
    filentest=strjoin([filen1,'tst'])

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
    statistics=dblarr(groupnum,3,100000)
    for i=0,nl-1,1 do begin
      for j=0,ns-1,1 do begin
        if (abs(is[1,j,i]-0) lt 0.0001) then begin
          is[0,j,i]=0
        endif
        if (abs(is[0,j,i]-0) lt 0.001) then begin
          is[0,j,i]=0
        endif
        if (abs(is[0,j,i]) lt ave*0.3) then begin ;若处理影子则改成0.3,曝光则0.05
          is[0,j,i]=0
        endif
      ;  if (abs(is[0,j,i]) gt ave*1.2) then begin ;若处理影子则去掉
      ;    is[0,j,i]=0
      ;  endif
      ;  if (abs(is[0,j,i]-ave) ge (ave)) then begin 
      ;    is[0,j,i]=0
      ;  endif
        if (abs(is[0,j,i]-0) gt 0.0001) then begin
          pointnum=ceil((is[1,j,i]-pmin)/0.1)
          count=statistics[pointnum-1,2,0]
          statistics[pointnum-1,0,count]=is[0,j,i]
          statistics[pointnum-1,1,count]=is[1,j,i]
          statistics[pointnum-1,2,0]=statistics[pointnum-1,2,0]+1
        endif
      endfor
    endfor

    sta=dblarr(2,groupnum)
    for group=0,groupnum-1 do begin
      sta[0,group]=total(statistics[group,0,*])/statistics[group,2,0]
      sta[1,group]=total(statistics[group,1,*])/statistics[group,2,0]
    endfor

    openw,lun3,filenresult,/get_lun
    printf,lun3,is
    print,filenresult
    free_lun,lun3
    openw,lun3,filensta,/get_lun
    printf,lun3,sta
    print,filensta
    free_lun,lun3
    openw,lun3,filentest,/get_lun
    printf,lun3,is[0,*,*]
    print,filentest
    free_lun,lun3

  endfor

end