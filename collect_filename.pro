pro collect_filename

filename=dialog_pickfile(filter='*.2B',/read,/multiple)
filelist=dialog_pickfile(filter='filelist.txt',/write)
number=size(filename)
num=number[3]
for i=0,num-1 do begin
  filename[i]=strmid(filename[i],15,66)
endfor

openw,lun,filelist,/get_lun
printf,lun,filename
free_lun,lun


end