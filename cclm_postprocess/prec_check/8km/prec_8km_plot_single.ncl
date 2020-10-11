;***************************************************************
; cmorph_4.ncl
;
; Concepts illustrated:
;   - Reading big endian binary files
;   - Reading records written by a fortran *direct access* write
;   - Reading CMORPH 8km data
;   - Adding meta data (attributes and coordinates [time, lat, lon])
;   - Explicitly setting contour levels and colors
;***************************************************************
;; ftp://ftp.cpc.ncep.noaa.gov/precip/global_CMORPH/README.cmorph.8km_30minute
;;
;; Each direct access record is a 4948 x 1649 CHARACTER*1 (use FORTRAN ichar
;; command to retrieve interger value for all parameters) array with  grid
;; increments of 0.072756669 degrees of longitude and 0.072771377 of latitude,
;; which is apporoximately 8 km at the equator.  The arrays are oriented from
;; North to South, beginning from latitude 59.963614N and from West to EAST from
;; longitude  0.036378335E.
;; 
;; Missing data are denoted by values of 255.
;; 
;; Note that the precipitation estimates have been scaled, and when multiplied by
;; "0.2", the data units are "mm/hour".
;; 
;; For GrADS users, a descriptor ("ctl") file: CMORPH_8km-30-minute.ctl has been
;; provided.  However, since the data are in CHARACTER*1 words (bytes) the parameters
;; after each variable (-1,40,1,-1 in our example "ctl file") are system dependent.  
;; Our example is for an SGI system.
;; 
;; Each file contains 6 records.  The 1st 3 records pertain to the top half
;; of the hour (00-29 minus after the hour) and the last 3 records are for the
;; bottom half of the hour.  Within each group:
;; 
;;   -  the 1st record contains the CMORPH precipitation estimates 
;;   
;;   -  the 2nd record contains the time (in half hour units) since the most
;;      recent microwave pass.  Note that since we do both a forward &
;;        backward interpolation in time, the nearest time may be prior to
;;        the file time stamp or after it.  
;;        
;;   -  the 3rd record contains an ID that tells the satellite from which the last
;;        microwave observation was made which can be interpretted by the following
;;        table (as of the time of the last update of this documentation):
;;        
;;        13 = DMSP-13 (SSM/I instrument)
;;        14 = DMSP-14 (  "       "      )
;;        15 = DMSP-15 (  "       "      )
;;        16 = DMSP-16 (SSMIS instrument, coming soon)
;;        17 = DMSP-17 ( " " )
;;        18 = DMSP-18 ( " " ) 
;;       115 = NOAA-15 (AMSU-B    "      )
;;       116 = NOAA-16 (  "       "      )
;;       117 = NOAA-17 (  "       "      )
;;       118 = NOAA-18 (MHS )
;;       119 = NOAA-19 ( " " )
;;       151 = METOP-A ( " " )
;;       201 = TRMM    (TMI       "      )
;;       211 = AQUA    (AMSR-E    "      )
;;   
;; 
;; Each direct access record is a 4948 x 1649 CHARACTER*1 (use FORTRAN ichar
;; command to retrieve interger value for all parameters) array with  grid
;; increments of 0.072756669 degrees of longitude and 0.072771377 of latitude,
;; which is apporoximately 8 km at the equator.  The arrays are oriented from
;; North to South, beginning from latitude 59.963614N and from West to EAST from
;; longitude  0.036378335E.
;; 
;; Missing data are denoted by values of 255.
;; 
;; Note that the precipitation estimates have been scaled, and when multiplied by
;; "0.2", the data units are "mm/hour".
;********************************************************************************

  diri  = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807_8km/"
  fili  = "CMORPH_V1.0_ADJ_8km-30min_2008072010"                   ; direct access (flat)
  pthi  = diri+fili

;;setfileoption("bin","ReadByteOrder","BigEndian")        ; *not* needed; input are type byte

  dlim  = "_-"                                            ; string delimiter
  nfld  = str_fields_count(fili, dlim)                    ; nfld=4
  ;;; 使用分隔符读取yyymmddhh，非常实用
  ymdh  = toint(str_get_field(fili, 6, dlim))             ; yyyymmddhh 
  print(ymdh)
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
  printMinMax(lat,0)

  lon   = 0.036378335d + ispan(0,nlon-1,1)*0.072756669d
  lon!0 = "lon"
  lon@units = "degrees_east"
  printMinMax(lon,0)

;---- Read 'top-half' of the hour (00-29 minus after the hour)
;     This is the 1st record (recnum=0)

  prc_u = fbindirread(pthi,3,(/ntim,nlat,nlon/),"ubyte")
  prc_u@_FillValue = toubyte(255)
  printMinMax(prc_u,0)

  prc = where(ismissing(prc_u), 1e20, prc_u*0.2)
  prc@_FillValue = 1e20
  delete(prc_u)                        ; no longer needed

  prc@long_name = "CMORPH 8km"
  prc@units     = "mm/hr"
  prc!0         = "time"
  prc!1         = "lat"
  prc!2         = "lon"
  prc&time      =  time
  prc&lat       =  lat
  prc&lon       =  lon
  printVarSummary(prc)
  printMinMax(prc,0)

  



  PLOT = True
  if (PLOT) then
      pltType = "png"                  ; send graphics to PNG file
      pltDir  = "./output_pic/"
      pltName = "cmorph_8km_check_single"   

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
  
      res@lbLabelBarOn         = False    ; turn off individual cb's
    
      ; res@mpMinLatF            = -60.     ; CMORPH limits [approx]
      ; res@mpMaxLatF            =  60.
      ; res@mpCenterLonF         = 210.
      ; res@mpFillOn             = False
      ; ; limit area
      res@mpLimitMode            = "Corners"
      res@mpLeftCornerLatF       = 15.99613   
      res@mpLeftCornerLonF       = 66.63403
      res@mpRightCornerLatF      = 44.66093
      res@mpRightCornerLonF      = 118.7213

      ; res@tiMainString           = "Native projection"
      ; res@pmTickMarkDisplayMode  = "always"

      ; pole_lat = 57.
      ; pole_lon = -91.5
      ; res@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
      ; res@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

      ; res@tiMainString           = "Native rotated lat/lon Projection"
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4
  
      nt   = 0
      ; res@tiMainString = fili
      plot = gsn_csm_contour_map(wks,prc(nt,:,:), res)
  end if    ; PLOT
 