pro ce4_angle_calcu
;v1.0
  cd,"D:\CE4data\3 PCAM\2B"
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]
  xyz=dblarr(3,2352,1728)
  data=dblarr(5,2352,1728)

  for picn=0,num-1 do begin
    filenam=filename[picn]
    filepos=strpos(filenam,'.2B')
    filehead=strmid(filenam,0,filepos)   
    fileuse=strjoin([filehead,'.2BL'])
    fileout=strjoin([filehead,'_geoinfo.img'])
    
    OpenR,lun,fileuse,/Get_Lun
    header =bytArr(6000)
    ReadU,lun,header
    header=string(header)
    strul='up_left_point_observe_vector'
    strdl='down_left_point_observe_vector'
    strur='up_right_point_observe_vector'
    strdr='down_right_point_observe_vector'
    strct='center_point_observe_vector'
    strsi='solar_incidence_angle'
    strsa='solar_azimuth_angle'

    ulpos=strpos(header,strul,/REVERSE_SEARCH)
    dlpos=strpos(header,strdl,/REVERSE_SEARCH)
    urpos=strpos(header,strur,/REVERSE_SEARCH)
    drpos=strpos(header,strdr,/REVERSE_SEARCH)
    ctpos=strpos(header,strct,/REVERSE_SEARCH)
    sipos=strpos(header,strsi,/REVERSE_SEARCH)
    sapos=strpos(header,strsa,/REVERSE_SEARCH)
;---------------------------------------------------------read vector
    count=0;ul
    ulz=double(strmid(header,ulpos-19,8))
    if strmid(header,ulpos-20,1) eq '-' then begin
      ulz=-ulz
      count=count+1
    endif
    uly=double(strmid(header,ulpos-40-count,8))
    if strmid(header,ulpos-41-count,1) eq '-' then begin
      uly=-uly
      count=count+1
    endif
    ulx=double(strmid(header,ulpos-61-count,8))
    if strmid(header,ulpos-62-count,1) eq '-' then begin
      ulx=-ulx
      count=count+1
    endif
    print,ulx,uly,ulz

    count=0;dl
    dlz=double(strmid(header,dlpos-19,8))
    if strmid(header,dlpos-20,1) eq '-' then begin
      dlz=-dlz
      count=count+1
    endif
    dly=double(strmid(header,dlpos-40-count,8))
    if strmid(header,dlpos-41-count,1) eq '-' then begin
      dly=-dly
      count=count+1
    endif
    dlx=double(strmid(header,dlpos-61-count,8))
    if strmid(header,dlpos-62-count,1) eq '-' then begin
      dlx=-dlx
      count=count+1
    endif
    print,dlx,dly,dlz
    
    count=0;ur
    urz=double(strmid(header,urpos-19,8))
    if strmid(header,urpos-20,1) eq '-' then begin
      urz=-urz
      count=count+1
    endif
    ury=double(strmid(header,urpos-40-count,8))
    if strmid(header,urpos-41-count,1) eq '-' then begin
      ury=-ury
      count=count+1
    endif
    urx=double(strmid(header,urpos-61-count,8))
    if strmid(header,urpos-62-count,1) eq '-' then begin
      urx=-urx
      count=count+1
    endif
    print,urx,ury,urz
    
    count=0;dr
    drz=double(strmid(header,drpos-19,8))
    if strmid(header,drpos-20,1) eq '-' then begin
      drz=-drz
      count=count+1
    endif
    dry=double(strmid(header,drpos-40-count,8))
    if strmid(header,drpos-41-count,1) eq '-' then begin
      dry=-dry
      count=count+1
    endif
    drx=double(strmid(header,drpos-61-count,8))
    if strmid(header,drpos-62-count,1) eq '-' then begin
      drx=-drx
      count=count+1
    endif
    print,drx,dry,drz
    
    count=0;ct
    ctz=double(strmid(header,ctpos-19,8))
    if strmid(header,ctpos-20,1) eq '-' then begin
      ctz=-ctz
      count=count+1
    endif
    cty=double(strmid(header,ctpos-40-count,8))
    if strmid(header,ctpos-41-count,1) eq '-' then begin
      cty=-cty
      count=count+1
    endif
    ctx=double(strmid(header,ctpos-61-count,8))
    if strmid(header,ctpos-62-count,1) eq '-' then begin
      ctx=-ctx
      count=count+1
    endif
    print,ctx,cty,ctz
    
    ;si
    si=double(strmid(header,sipos-11,9))
    print,si
        
    ;sa
    sa=double(strmid(header,sapos-11,9))
    if strmid(header,sapos-12,1) ne '>' then begin
      sa=sa+100*strmid(header,sapos-12,1)
    endif
    print,sa
;---------------------------------------------------------calculate for each pixel
    for j=double(0),1727 do begin
      for i=double(0),2351 do begin
        x=((2351-i)/2351*ulx+i/2351*urx)*(1727-j)/1727+((2351-i)/2351*dlx+i/2351*drx)*j/1727
        y=((2351-i)/2351*uly+i/2351*ury)*(1727-j)/1727+((2351-i)/2351*dly+i/2351*dry)*j/1727
        z=((2351-i)/2351*ulz+i/2351*urz)*(1727-j)/1727+((2351-i)/2351*dlz+i/2351*drz)*j/1727
        r=sqrt(x^2+y^2+z^2)
        xyz[0,i,j]=x/r
        xyz[1,i,j]=y/r
        xyz[2,i,j]=z/r
      endfor
    endfor
    
    ;cam_ze,cam_az,sun_ze,sun_az,pha
    for i=0,2351 do begin
      for j=0,1727 do begin
        data[2,i,j]=si
        data[3,i,j]=sa
        data[0,i,j]=180-acos(xyz[2,i,j])/!pi*180
        data[1,i,j]=atan(xyz[0,i,j]/xyz[1,i,j])/!pi*180
        x1=sin(data[1,i,j]/180*!pi)*sin(data[0,i,j]/180*!pi)
        y1=cos(data[1,i,j]/180*!pi)*sin(data[0,i,j]/180*!pi)
        z1=cos(data[0,i,j]/180*!pi)
        x2=sin(data[3,i,j]/180*!pi)*sin(data[2,i,j]/180*!pi)
        y2=cos(data[3,i,j]/180*!pi)*sin(data[2,i,j]/180*!pi)
        z2=cos(data[2,i,j]/180*!pi)
        ab=sqrt((x1-x2)^2+(y1-y2)^2+(z1-z2)^2)
        data[4,i,j]=acos((2-ab^2)/2)/!pi*180
      endfor
    endfor
    
    data2=dblarr(2352,1728,5)
    for i=0,4 do begin
      data2[*,*,i]=data[i,*,*]
    endfor
    ENVI_WRITE_ENVI_FILE,data2,out_name=fileout,NB=nb, NL=nl, NS=ns
  endfor

end