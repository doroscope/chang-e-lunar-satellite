pro read_data

file=dialog_pickfile()
openr,lun,file,/get_lun
;header=fstat(lun)
;help,header,/structure
;print,header.size
;size=header.size
data=dblarr(7,2352,1729)
;b=0
;for i=0,1727 do b+=TOTAL(data ge 100)
readf,lun,data
;help,data
print,data[0,0,0],data[1,0,0],data[2,0,0],data[3,0,0],data[4,0,0],data[5,0,0]
data5=data[5,*,*]
openw,lun2,'d:\is2.txt',/get_lun
printf,lun2,data
free_lun,lun
free_lun,lun2

end