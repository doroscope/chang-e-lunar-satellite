pro add_hdr2
  ;for_TCAM2C
  filename=dialog_pickfile(filter='*.2C',/read,/multiple)
  number=size(filename)
  num=number[3]

  cont=["ENVI"+STRING(13b)+$
    "description = {"+STRING(13b)+$
    "File Imported into ENVI.}"+STRING(13b)+$
    'samples = 2352'+STRING(13b)+$
    'lines   = 1728'+STRING(13b)+$
    'bands   = 3'+STRING(13b)+$
    'header offset = 0'+STRING(13b)+$
    'file type = ENVI Standard'+STRING(13b)+$
    'data type = 1'+STRING(13b)+$
    'interleave = bip'+STRING(13b)+$
    'sensor type = Unknown'+STRING(13b)+$
    'byte order = 0'+STRING(13b)+$
    "wavelength units = Unknown"]
  for picn=0,num-1 do begin
    filenam=filename[picn]
    filepos=strpos(filenam,'.2C')
    filehead=strmid(filenam,0,filepos)
    outfile=strjoin([filehead,'.HDR'])
    openw,lun,outfile,/get_lun
    printf,lun,cont
    free_lun,lun
  endfor

end