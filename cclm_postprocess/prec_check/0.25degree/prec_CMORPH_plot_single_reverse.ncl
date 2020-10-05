;   2020.10.04 用于CMORPH读入数据的脚本
;              简单地调整了绘图参数，让他和之前的native的格点绘制地相似
;              简单的绘制，用于后续绘图的参考，以及数据检查
;              参考脚本有缺陷，本身只有反演的降水的数据，每日具有3小时的数据。一共0-7，共八个层次的数据
;  2020.10.05
;              用于绘制一张CMORPH 3HR 0.25degree 的结果。用于检验
;              .reverse 是为了说明正确的二进制文件读取顺序，绘图明显是错误的
load "./quantile.ncl"   ;  用于检查的分位数的函数
begin

diri   = "/m2data2/yycheng/data_stage/cptp/check_data_obs/CMORPH/200807/"
fili  = systemfunc("cd "+diri+"; ls *CMORPH*")
nfil  = dimsizes(fili)

;***************************************************************
; Read (big endian) binary file
;***************************************************************
;    setfileoption("bin","ReadByteOrder","BigEndian") ; 居然关掉就好了？10.04 读入CPC数据

   nlat  = 480                                    ; from ctl file  
   mlon  = 1440

;    print(diri+fili(0)) ; check file path
;  读取不同层次的降水数据
   comb  = fbindirread(diri+fili(19),0, (/mlon,nlat/),"float")
   cpc   = fbindirread(diri+fili(19),7, (/mlon,nlat/),"float")
   print(fili(19))
;***************************************************************
; Add meta data
;***************************************************************
   comb@_FillValue = -9999.
   comb@units      = "mm/hr"
   comb@long_name  = "Merged microwave precip (no advection)" 

   cpc@_FillValue  = -9999.
   cpc@units       = "mm/hr"
   cpc@long_name   = "CMORPH precip"

;***************************************************************
; Change from mm/hr to mm/day
;***************************************************************
;    comb            = comb*24    
;    cpc             = cpc*24    
;    comb@units      = "mm/day"
;    cpc@units       = "mm/day"

;***************************************************************
; Create/Add coordinate variables. See above Grads ctl   
;***************************************************************
   lat       =  59.875 - ispan(0,nlat-1,1)*0.25  
   lon       =   0.125 + ispan(0,mlon-1,1)*0.25 
                                        ;latitude
   lat!0     = "lat"
   lat&lat   =  lat
   lat@units = "degrees_north"
                                        ;longitude
   lon!0     = "lon"
   lon&lon   =  lon
   lon@units = "degrees_east"

;***************************************************************
; Associate the spatial coordinates with variables
;***************************************************************

   comb!0    = "lon"
   comb!1    = "lat"                   ; 1st ... name the dimensions
   comb&lat  =  lat                    ; create coordinate variable
   comb&lon  =  lon                    ; create coordinate variable

   copy_VarCoords( comb, cpc )         ; same coordinates

; printVarSummary(comb) ; output to nc
; printVarSummary(cpc)  ; output to nc

; print(percent_to_value(cpc,ispan(90, 100, 1)))

;***************************************************************
; Simple data exploration: 
;    Are there missing data?
;    Count the number of missing values in each variable
;    Calculate weighted areal averages: ignore missing grid points
;    Calculate weighted areal averages of precip occurrence only
; Print results
;***************************************************************

   nMsg_comb = num(ismissing(comb))
   nMsg_cpc  = num(ismissing(cpc ))

   ; rad      = 4.*atan(1.0)/180.
   ; clat_025 = cos(lat*rad)    ; simple cosine weighting

   ; combAvg_025 = wgt_areaave(comb, clat_025, 1.0, 0)
   ; cpcAvg_025  = wgt_areaave( cpc, clat_025, 1.0, 0)

   ; print(" ")
   ; print("Number missing: nMsg_comb="+nMsg_comb+"   nMsg_cpc="+nMsg_cpc)
   ; print(" ")
   ; print("Original 0.25 grid: combAvg="+combAvg_025+"   cpcAvg="+cpcAvg_025)
   ; print(" ")

 wks    = gsn_open_wks("png", "./output_pic/cpc_check_reverse_lat_lon")
   
       plot = new ( 2 , "graphic")
     
       res                      = True         ; plot mods desired
       res@gsnDraw              = False        ; don't draw
       res@gsnFrame             = False        ; don't advance frame
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnLinesOn            = False    ; turn of contour lines
      ;res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines

       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day" 
       res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                                   ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels

       res@cnMissingValFillPattern = 0         ; make 'missing' black
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
     
       res@mpMinLatF            = -60.     ; CMORPH limits [approx]
       res@mpMaxLatF            =  60.
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
   
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4

        ; limit area
      ;   res@mpLimitMode            = "Corners"
      ;   res@mpLeftCornerLatF       = 15.99613   
      ;   res@mpLeftCornerLonF       = 66.63403
      ;   res@mpRightCornerLatF      = 44.66093
      ;   res@mpRightCornerLonF      = 118.7213

      ;   res@tiMainString           = "Native projection"
      ;   res@pmTickMarkDisplayMode  = "always"

      ;   pole_lat = 57.
      ;   pole_lon = -91.5
      ;   res@mpCenterLatF           = 90 - pole_lat  ; north_pole_lat=6.55
      ;   res@mpCenterLonF           = 180 + pole_lon ; north_pole_lon=0

      ;   res@tiMainString           = "Native rotated lat/lon Projection"

        ;



   
      ;  res@gsnCenterString = "Areal Mean="+sprintf("%4.2f", combAvg_025)
       plot(0) = gsn_csm_contour_map(wks,comb, res)
   
      ;  res@gsnCenterString = "Areal Mean="+sprintf("%4.2f",  cpcAvg_025)
       plot(1) = gsn_csm_contour_map(wks,cpc, res)
   
      ;delete(work)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
    ;    resP@gsnPanelMainString  = "CMORPH: "+fili
       gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot



end