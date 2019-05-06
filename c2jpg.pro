pro c2jpg
;将2c文件转为jpg
filename=dialog_pickfile(filter='*.2C',/read,/multiple)
number=size(filename)
num=number[3]

data=bytarr(2352,1728,3)
data2=bytarr(3,2352,1728)
for picn=0,num-1 do begin
  filenam=filename[picn]
  filepos=strpos(filenam,'.2C')
  filehead=strmid(filenam,0,filepos)
  outfile=strjoin([filehead,'.jpg'])
  envi_open_file,filenam,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
  for i=0,2 do begin
      data[*,*,i]= ENVI_GET_DATA(fid=fid, dims=dims, pos=i)
  endfor
  for i=0,2 do begin
    data2[i,*,*]=data[*,*,i]
  endfor
  WRITE_JPEG, outfile, data2, /ORDER, QUALITY=75, /TRUE
endfor



end