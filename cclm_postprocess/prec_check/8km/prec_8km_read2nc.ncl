;         10.12   将一个文件夹中的8km的cmorph的文件进行合并，并输出到NC文件中
;                 仅仅处理一个文件，用以读入数据的验证，附带有简单的绘图部分  
; load "../0.25degree/quantile.ncl"
begin
  diri  = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807_8km/"
  fili  = "CMORPH_V1.0_ADJ_8km-30min_2008072315"                   ; direct access (flat)
  pthi  = diri+fili

        ;  if (isbigendian() ) then
        ; print(isbigendian()) ; FALSE
            ;  setfileoption("bin", "RecordMarkerSize", 4)
        ;  end if

; setfileoption("bin","ReadByteOrder","littleEndian")        ; *not* needed; input are type byte
setfileoption("bin","RecordMarkerSize",8)

  dlim  = "_-"                                            ; string delimiter
  nfld  = str_fields_count(fili, dlim)                    ; nfld=4
  ;;; 使用分隔符读取yyymmddhh，非常实用
  ymdh  = toint(str_get_field(fili, 6, dlim))             ; yyyymmddhh 
  ; print(ymdh)
  yyyy  = ymdh/1000000
  mdh   = ymdh - yyyy*1000000
  mm    = mdh/10000
  dh    = mdh - mm*10000
  dd    = dh/100
  hh    = dh-dd*100

  tunits= "hours since 2000-01-01 00:00:00"                ; arbitrary date
  time  = cd_inv_calendar(yyyy,mm,dd,hh, 0, 0,tunits, 0)
  time!0= "time"
  
  ntim  = 1
  nlat  = 1649
  nlon  = 4948 

  lat   = 59.963614d - ispan(0,nlat-1,1)*0.072771377d    ; N->S
  lat!0 = "lat"
  lat@units = "degrees_north"
  ; printMinMax(lat,0)

  lon   = 0.036378335d + ispan(0,nlon-1,1)*0.072756669d
  lon!0 = "lon"
  lon@units = "degrees_east"
  ; printMinMax(lon,0)

;---- Read 'top-half' of the hour (00-29 minus after the hour)
;     This is the 1st record (recnum=0)
  ; setfileoption("bin","ReadByteOrder","Little")
i=1
  print("record number is :"+ i)
  ; prc_u = fbindirread(pthi,i,(/nlat,nlon/),"ubyte")
  prc_u = fbindirread(pthi, i, (/nlat, nlon/), "float")
  ; prc_u1 = fbindirread(pthi,3,(/ntim,nlat,nlon/),"ubyte")
  prc_u@_FillValue = -999
  printMinMax(prc_u,0)
  ; drop 0.2
  prc = where(ismissing(prc_u), 1e20, prc_u*0.2)
  prc@_FillValue = 1e20
  delete(prc_u)                        ; no longer needed

  prc@long_name = "CMORPH 8km"
  prc@units     = "mm/hr"
  ; prc!0         = "time"
  prc!0         = "lat"
  prc!1         = "lon"
  ; prc&time      =  time
  prc&lat       =  lat
  prc&lon       =  lon
  ; printVarSummary(prc)
  ; printMinMax(prc,0)
  ; print(percent_to_value(prc,ispan(90, 100, 1)))
  ; print(get_unique_values(prc))
; end do

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