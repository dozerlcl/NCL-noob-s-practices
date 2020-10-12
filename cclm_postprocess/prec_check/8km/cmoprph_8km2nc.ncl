;         10.12   将一个文件夹中的8km的cmorph的文件进行合并，并输出到NC文件中
  ; load "../0.25degree/quantile.ncl"
begin
  diri  = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807_8km/"
  fili  = systemfunc("cd "+diri+"; ls *CMORPH*")              ; direct access (flat)
  pthi  = diri+fili
  nfil   = dimsizes(fili)

  netCDF = True
  if(netCDF) then
    ncDir  = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807_8km_nc/"     ;   创建在上一级目录中，具体自己修改
    ncFil  = fili + ".nc"
    NCFILE = ncDir + ncFil
  end if

  ; if (isbigendian() ) then
  ;     setfileoption("bin", "RecordMarkerSize", 4)
  ; end if
  setfileoption("bin","RecordMarkerSize",8)
do ind_fili = 0, nfil - 1;nfil -1,1
;;;>>>>> form coordinates
  dlim  = "_-"                                            ; string delimiter
  nfld  = str_fields_count(fili(ind_fili), dlim)                    ; nfld=4
  ;;; 使用分隔符读取yyymmddhh，非常实用
  ymdh  = toint(str_get_field(fili(ind_fili), 6, dlim))             ; yyyymmddhh 
  yyyy  = ymdh/1000000
  mdh   = ymdh - yyyy*1000000
  mm    = mdh/10000
  dh    = mdh - mm*10000
  dd    = dh/100
  hh    = dh-dd*100

  tunits= "hours since 1990-01-01 00:00:00"
  time  = new(2, double)                ; arbitrary date
  ; test_time  = cd_inv_calendar(yyyy,mm,dd,hh, 0,  0,tunits, 0)
  ; printVarSummary(test_time)
  time(0)  = cd_inv_calendar(yyyy,mm,dd,hh, 0,  0,tunits, 0)
  time(1)  = cd_inv_calendar(yyyy,mm,dd,hh, 30, 0,tunits, 0)
  time!0= "time"
  
  ntim  = 2
  nlat  = 1649
  nlon  = 4948 

  lat   = 59.963614d - ispan(0,nlat-1,1)*0.072771377d    ; N->S
  lat!0 = "lat"
  lat@units = "degrees_north"

  lon   = 0.036378335d + ispan(0,nlon-1,1)*0.072756669d
  lon!0 = "lon"
  lon@units = "degrees_east"

;;;>>>>>Read 'top-half' of the hour (00-29 minus after the hour and 30-59minus)
  ; contatin 2 records, read together and combine them into one time series
  print("file_ind is :"+ind_fili+" "+pthi(ind_fili))
  prc = fbindirread(pthi(ind_fili), 0, (/ntim, nlat, nlon/), "float")
  prc@_FillValue = -999
  printMinMax(prc,0)
  ; drop 0.2 convert unit to mm/hr
  prc = where(ismissing(prc), prc@_FillValue, prc*0.2)

;;;>>>>> add coordinates 
  prc@long_name = "CMORPH 8km"
  prc@units     = "mm/hr"
  prc!0         = "time"
  prc!1         = "lat"
  prc!2         = "lon"
  prc&time      =  time
  prc&lat       =  lat
  prc&lon       =  lon

  ; printVarSummary(prc)


  ;************************************************
  ; Create netCDF
  ; Recommend to always create a 'time' dimension
  ;************************************************

  nline  = inttochar(10)

  globeAtt              = 1
  globeAtt@Conventions  = "CF-1.0"
  globeAtt@title        = "CMORPH: 8km Hourly"
  globeAtt@ftp          = "ftp://ftp.cpc.ncep.noaa.gov/precip/global_CMORPH/30min_8km"
  globeAtt@acronym      = "CMORPH: CPC Morphing Technique"
  globeAtt@description  = "http://www.cpc.noaa.gov/products/janowiak/cmorph_description.html"
  globeAtt@referenceon  = nline + \
    "Joyce, R. J., J. E. Janowiak, P. A. Arkin, and P. Xie, 2004:       "+nline+\
    "CMORPH: A method that produces global precipitation estimates      "+nline+\
    "        from passive microwave and infrared data at high spatial   "+nline+\
    "        and temporal resolution. J. Hydromet., 5, 487-503.         "+nline

  globeAtt@creation_date= systemfunc ("date" )


  system("rm -f " +  NCFILE(ind_fili))    ; remove any pre-exist file
  ncdf   = addfile(NCFILE(ind_fili),"c")
  ;setfileoption(ncdf, "definemode", True)

  fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

  dimNames = (/"time", "lat", "lon" /)
  dimSizes = (/ ntim ,  nlat,  nlon /)
  dimUnlim = (/ True , False, False /)
  filedimdef(ncdf, dimNames  , dimSizes,  dimUnlim )

  filevardef   (ncdf, "time"  , typeof(time), getvardims(time) )
  filevarattdef(ncdf, "time", time)

  filevardef   (ncdf, "lat", typeof(lat), getvardims(lat))
  filevarattdef(ncdf, "lat", lat)

  filevardef   (ncdf, "lon", typeof(lon), getvardims(lon))
  filevarattdef(ncdf, "lon", lon)

  filevardef    (ncdf, "CMORPH"  , typeof(prc) , getvardims(prc) )
  filevarattdef (ncdf, "CMORPH"  , prc)

  ncdf->time   = (/ time /)
  ncdf->lat    = (/ lat /)
  ncdf->lon    = (/ lon /)
  ncdf->CMORPH = (/ prc /)


end do

  ; check for plot
  PLOT = False
  if (PLOT) then
      pltType = "png"                  ; send graphics to PNG file
      pltDir  = "./output_pic/"
      pltName = "cmorph_8km_check_single_rec3"   

      wks    = gsn_open_wks(pltType, pltDir+pltName)
  
      res                      = True         ; plot mods desired
      res@gsnMaximize          = True
    
      res@cnFillOn             = True     ; turn on color fill
      res@cnLinesOn            = False    ; turn of contour lines
     res@cnFillMode           = "CellFill"           ; Cell Mode
      ; res@cnFillMode           = "RasterFill"         ; Raster Mode
      res@cnLinesOn            =  False       ; Turn off contour lines
      res@cnLineLabelsOn       =  False       ; Turn off contour lines

      res@cnLevelSelectionMode = "ExplicitLevels"              
      res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day" 
      res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                                  ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels

      res@cnMissingValFillPattern = 0         ; make 'missing' black
      res@cnMissingValFillColor   = "black"
  
    ;   res@lbLabelBarOn         = False    ; turn off individual cb's
    
      res@mpMinLatF            = -60.     ; CMORPH limits [approx]
      res@mpMaxLatF            =  60.
      res@mpCenterLonF         = 210.
      res@mpFillOn             = False
      ; limit area
      res@mpLimitMode            = "Corners"
      res@mpLeftCornerLatF       = 15.99613   
      res@mpLeftCornerLonF       = 66.63403
      res@mpRightCornerLatF      = 44.66093
      res@mpRightCornerLonF      = 118.7213
      ; res@mpLeftCornerLatF

      res@tiMainString           = "Native projection"
      res@pmTickMarkDisplayMode  = "always"

      pole_lat = 57.
      pole_lon = -91.5
      res@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
      res@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

      res@tiMainString           = "Native rotated lat/lon Projection"
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4
  
      nt   = 0
      ; res@tiMainString = fili
      plot = gsn_csm_contour_map(wks,prc(:,:), res)
  end if    ; PLOT
 
 end